import json
import math
import random
import sys
import pygomas
from pygomas.map import TerrainMap
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdisoldier import BDISoldier
from pygomas.bdimedic import BDIMedic
from pygomas.bdifieldop import BDIFieldOp
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions
from pygomas.ontology import HEALTH

from pygomas.agent import LONG_RECEIVE_WAIT


class SquardGeneral(BDITroop):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".delete", (int, tuple))
        def _delete(p, l):
            '''
                Función para eliminar el elemento en la posición indicada ya que el
                método por defecto de Pygomas no funciona.

                p: posición en la lista.
                l: lista.

                return: lista sin el elemento en la posición.
            '''
            if p == 0:
                return l[1:]
            elif p == (len(l) - 1):
                return l[:p]
            else:
                return tuple(l[0:p] + l[p + 1:])

        @actions.add_function(".medicoMasCerca", (tuple, tuple))
        def _medico_mas_cercano(pos_sol, pos_agents):
            '''
                Elige el médico más cercano.

                pos_sol: Posicion de la unidad que solicita la ayuda.
                pos_agents: La lista de las posiciones de los médicos.

                return: La posición del médico más cercano.
            '''

            # Lista resultado de distancia a cada agente
            dist_agent = []

            # Recorremos la lista de agentes
            for pos_agent in pos_agents:
                dist_agent += [math.sqrt(math.pow(
                    pos_agent[0] - pos_sol[0], 2) + math.pow(pos_agent[2] - pos_sol[2], 2))]

            # Ordenamos de menor a mayor distanca Euclidea
            dist_aux = tuple(sorted(dist_agent))
            res = []
            if (len(dist_aux) > 0):
                res += [dist_agent.index(dist_aux[0])]
            # Si este método se activa siempre habrá, al menos, un operativo
            # Devolvemos la posicón del agente más cercano
            return tuple(res)

        @actions.add_function(".operativoMasCerca", (tuple, tuple))
        def _operativo_mas_cercano(pos_sol, pos_agents):
            '''
                Elige el operativo más cercano.

                pos_sol: Posicion de la unidad que solicita la ayuda.
                pos_agents: La lista de las posiciones de los operativos.

                return: La posición del operativo más cercano.
            '''

            # Lista resultado de distancia a cada agente
            dist_agent = []

            # Recorremos la lista de agentes
            for pos_agent in pos_agents:
                dist_agent += [math.sqrt(math.pow(
                    pos_agent[0] - pos_sol[0], 2) + math.pow(pos_agent[2] - pos_sol[2], 2))]

            # Ordenamos de menor a mayor deistancia Euclidea
            dist_aux = sorted(dist_agent)

            res = []
            if (len(dist_aux) > 0):
                res += [dist_agent.index(dist_aux[0])]
            # Si este método se activa siempre habrá, al menos, un operativo
            # Devolvemos la posicón del agente más cercano
            return tuple(res)

        @actions.add_function(".agentesMasCercanos1", (tuple, tuple))
        def _agentes_mas_cercanos1(pos_ene, pos_agents):
            '''
            Recibe dos parametros:
                pos_ene: Posicion del agente enemigo detectado.
                pos_agents: La lista de las posiciones de los agentes.

            return: La posición del agente más cercano.
            '''
            # Lista resultado de distancia a cada agente
            dist_agent = []

            # Recorremos la lista de agentes
            for pos_agent in pos_agents:
                dist_agent += [math.sqrt(math.pow(
                    pos_agent[0] - pos_ene[0], 2) + math.pow(pos_agent[2] - pos_ene[2], 2))]

            # Ordenamos de menor a mayor distancia Euclidea
            dist_aux = sorted(dist_agent)
            # Si este método se activa siempre habrá, al menos, un operativo
            # Devolvemos la posicón del agente más cercano
            res = []
            if len(dist_aux) > 0:
                res += [dist_agent.index(dist_aux[0])]

            return tuple(res)

        @actions.add_function(".agentesMasCercanos2", (tuple, tuple))
        def _agentes_mas_cercanos2(pos_ene, pos_agents):
            '''
            Recibe dos parametros:
                pos_ene: Posicion del agente enemigo detectado.
                pos_agents: La lista de las posiciones de los agentes.

            return: La posición del agente más cercano.
            '''
            # Lista resultado de distancia a cada agente
            dist_agent = []

            # Recorremos la lista de agentes
            for pos_agent in pos_agents:
                dist_agent += [math.sqrt(math.pow(
                    pos_agent[0] - pos_ene[0], 2) + math.pow(pos_agent[2] - pos_ene[2], 2))]

            # Ordenamos de menor a mayor distancia Euclidea
            dist_aux = sorted(dist_agent)
            # Si este método se activa siempre habrá, al menos, un operativo
            # Devolvemos la posicón del agente más cercano
            res = []
            if len(dist_aux) > 1:
                res += [dist_agent.index(dist_aux[0])]
                res += [dist_agent.index(dist_aux[1])]

            return tuple(res)

        

        @actions.add_function(".fuegoAmigo", (tuple, tuple, tuple))
        def _fuegoAmigo(pos_propia, pos_enemigo, pos_aliado):
            '''
                Comprueba si hay un amigo en el angulo de tiro. Más formalmente, comprueba si la posición
                del aliado se encuentra en la recta que una la posición del tirador con la del objetivo.
            '''
            crossproduct = (pos_aliado[2] - pos_propia[2]) * (pos_enemigo[0] - pos_propia[0]) - (
                    pos_aliado[0] - pos_propia[0]) * (pos_enemigo[2] - pos_propia[2])

            if abs(crossproduct) > sys.float_info.epsilon:
                return False

            dotproduct = (pos_aliado[0] - pos_propia[0]) * (pos_enemigo[0] - pos_propia[0]) + (
                    pos_aliado[2] - pos_propia[2]) * (pos_enemigo[2] - pos_propia[2])
            if dotproduct < 0:
                return False

            squaredlengthba = (pos_enemigo[0] - pos_propia[0]) * (pos_enemigo[0] - pos_propia[0]) + (
                    pos_enemigo[2] - pos_propia[2]) * (pos_enemigo[2] - pos_propia[2])
            if dotproduct > squaredlengthba:
                return False

            return True


    
