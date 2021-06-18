/* Creencia que se dispara cuando se inicia la partida */
+flag(F)
	<-
	.print("PATRULLA");
	!generarPatrulla.


/* El agente gira mientras patrulla */
+!rolling(Rot)
	<-
	.turn(Rot);
	.wait(250);
	!!rolling(Rot + 1.57).

/* ESTRATEGIA DE PATRULLA EN CIRCULO (EXTERIOR) */
/* Generamos unos puntos de control en CIRCULO */
+!generarPatrulla
	<-
	.get_service("general");
	?flag(F);
	.circuloExterior(F, C);
	+control_points(C);
	.length(C, L);
	+total_control_points(L);
	+patrullando;
	!!rolling(1.57);
	+punto_patrullar(0).

+target_reached(T): patrullando
	<-
	?punto_patrullar(P);
	-+punto_patrullar(P + 1);
	-target_reached(T).

+punto_patrullar(P): total_control_points(T) & P < T
	<-
	?control_points(C);
	.nth(P, C, A);
	.goto(A).

+punto_patrullar(P): total_control_points(T) & P == T
	<-
	-punto_patrullar(P);
	+punto_patrullar(0).
  

/* ESTRATEGIA DE PAQUETES DE SALUD */
/* Creencia que anula la estrategia */
+health(H): H >= 20 & solicitandoSalud
	<-
	-solicitandoSalud.

/* Creencia que dispara la estrategia */
+health(H): H < 20 & not solicitandoSalud
	<-
	+solicitandoSalud.

/* Solicitud al general */
+solicitandoSalud
	<-
	-+medicoPOS([]);
	-+medicoID([]);
	.get_service("general");
	.wait(500);
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudSalud(Pos));
	.wait(1500).



/* ESTRATEGIA DE PAQUETES DE MUNICIÓN */
/* Creencia que anula la estrategia */
+ammo(A): A >= 20 & solicitandoAmmo
	<-
	-solicitandoAmmo.

/* Creencia que dispara la estrategia */
+ammo(A): A < 20 & not solicitandoAmmo
	<-
	+solicitandoAmmo.

/* Solicitud al general */
+solicitandoAmmo
	<-
	-+operativoPOS([]);
	-+operativoID([]);
	.get_service("general");
	.wait(500);
	?general(General);
	?position(Pos);
	.send(General, tell, solicitudAmmo(Pos));
	.wait(1500).


/* Visualizo un enemigo y no he avisado al General */	
+enemies_in_fov(_, _, _, _, _, Position): not solicitandoAtaque & not atacando
	<-
	+solicitandoAtaque;
	?general(General);
	.send(General, tell, solicitudEstrategia(Position));
	.look_at(Position);
    .shoot(10, Position).

/* Visualizo un enemigo */
+enemies_in_fov(_, _, _, _, _, Position): solicitandoAtaque | atacando
	<-
	.look_at(Position);
	
	+puedoDisparar;
	while (friends_in_fov(Q,W,E,R,T,AmigoPos) & puedoDisparar) {
		?position(MiPosicion);
		.fuegoAmigo(MiPosicion, Position, AmigoPos, Aux);
		if (Aux) {
		.print("ALTO EL FUEGO!");
			-puedoDisparar;
		}
		-friends_in_fov(Q,W,E,R,T,AmigoPos);
	}
	
	if (puedoDisparar) {
		.shoot(2, Position);
	}
	
	-puedoDisparar.
	
/* Atacar en grupo de 2 */	
+solicitudEst(Pos)[source(A)]: not atacando
	<-
	?position(MiPos);
	.send(A, tell, respuestaEstrategiaS(MiPos));
	+ayudandoc(Pos);
	-solicitudEst(_).
	
/* Me aceptan la respuesta de solicitud de apoyo */
+solicitudAceptadaEst(Pos)[source(A)]
	<-
	-control_points(_);
	-total_control_points(_);
	-patrullando;
	+atacando;
	.goto(Pos);
	-solicitudAceptadaEst(_).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegadaEst[source(A)]
	<-
	-ayudandoc(Pos).
	
/* Llego al objetivo del ataque */
+target_reached(Pos): atacando & solicitandoAtaque
	<-
	-atacando;
	-solicitandoAtaque;
	!generarPatrulla.