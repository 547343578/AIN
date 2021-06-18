/* Creencia que se dispara cuando se inicia la partida */
+flag(F): team(200)
	<-
	.print("PATRULLA MEDIC");
	!generarPatrulla.

/* El agente gira mientras patrulla */
+!rolling(Rot)
	<-
	.turn(Rot);
	.wait(250);
	!!rolling(Rot + 1.57).


/* ESTRATEGIA DE PATRULLA EN CIRCULO (INTERIOR) */
/* Generamos unos puntos de control en CIRCULO */
+!generarPatrulla
	<-
	.get_service("general");
	?flag(F);
	.circuloInterior(F, C);
	+control_points(C);
	.length(C, L);
	+total_control_points(L);
	+patrullando;
	!!rolling(1.57);
	+punto_patrullar(0).



+target_reached(T): patrullando & team(200) 
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
  
  
// ESTRATEGIA DE RECEPCIÓN Y ENVIAMIENTO DE SOLICITUDES DE AYUDA DE SALUD
/* Recibo solictud de ayuda */
+solicitudSalud(Pos)[source(A)]: not (ayudando(_,_))
	<-
	?position(MiPos);
	.send(A, tell, respuestaVida(MiPos));
	+ayudando(A, Pos);
	-solicitudSalud(_).
	
/* Me aceptan la respuesta de solicitud de ayuda */
+solicitudAceptada[source(A)]: ayudando(A, Pos)
	<-
	-control_points(_);
	-total_control_points(_);
	-patrullando;
	-punto_patrullar(_);
	.goto(Pos).
	
/* Me rechazan la respuesta de solicitud de ayuda */
+solicitudDenegada[source(A)]: ayudando(A, Pos)
	<-
	-ayudando(A, Pos).

/* Voy a la posición del agente que me ha aceptado */
+target_reached(T): ayudando(A, T)
	<-
	.cure;
	-ayudando(_, _);
	!generarPatrulla.


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
