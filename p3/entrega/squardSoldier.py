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


class SquardSoldier(BDISoldier):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)
        
        @actions.add_function(".circuloExterior", (tuple))
        def _circulo_exterior(pos_flag):
            '''
            Recibe un parametro: La posicición de la bandera.

            return: La lista de puntos de patrulla en circulo exterior.
            '''
            # Distancia de creación del círculo
            dist_circulo = 20

            punto_A = [pos_flag[0] - dist_circulo,
                       pos_flag[1], pos_flag[2]]
            punto_B = [pos_flag[0], pos_flag[1],
                       pos_flag[2] - dist_circulo]
            punto_C = [pos_flag[0] + dist_circulo,
                       pos_flag[1], pos_flag[2]]
            punto_D = [pos_flag[0], pos_flag[1],
                       pos_flag[2] + dist_circulo]
            pos = [tuple(punto_A), tuple(punto_B),
                         tuple(punto_C), tuple(punto_D)]
            pos = random.sample(pos, len(pos))
            return tuple(pos)
            

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
