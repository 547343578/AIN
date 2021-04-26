/* CREENCIAS INICIALES */

centro([130, 0, 130]). 		
esquinas([[0,0,0],[250,0,0],[250,0,250],[0,0,250]]). 


/* CREENCIAS A DISPARAR */

+flag(F): team(200)
    <-
	+yendoAlCentro;
	/*+entrada(0);*/
	!irAlCentro.


+friends_in_fov(ID, Type, Angle, Distance, Health, Position): health(H) & H > Health & ammo(A) & A > 0
    <-
	-patrullandoCentro;
	!matar(Position).
	
	
+friends_in_fov(ID, Type, Angle, Distance, Health, Position): health(H) & (H <= Health | ammo(A) & A <= 0)
    <-
	!irAlCentro.

	
+packs_in_fov(ID, Type, Angle, Distance, Health, Position): Type = 1001 & (not yendoAPorPaquete(1001)) & health(H) & H < 100
	<-
	-patrullandoCentro;
	-yendoAlCentro;
	+yendoAPorPaquete(1001);
	!irAPorPaquete(Position).
	
	
+packs_in_fov(ID, Type, Angle, Distance, Health, Position): Type = 1002 & (not yendoAPorPaquete(_)) & ammo(A) & A < 100
	<-
	-patrullandoCentro;
	-yendoAlCentro;
	+yendoAPorPaquete(1002);
	!irAPorPaquete(Position).


+target_reached(T): centro(C) & C==T
    <-
	-yendoAlCentro;
	+patrullandoCentro;
	!patrullarCentro.



/* PLANES */

+!irAlCentro
	<-
	?centro(Pos);
	.goto([130, 0, 130]).


+!matar(Position): health(H) & H > 30
	<-
	.shoot(5, Position);
	.look_at(Position);
	.goto(Position).


-!matar(_)
	<-
	!irAlCentro.


+!patrullarCentro: /*entrada(E) & E < 4 & */ patrullandoCentro
    <-
	/*?esquinas(Esq);
	.nth(E,Esq,R);
	.look_at(R);
	-entrada(E);
	+entrada(E + 1);*/
	.turn(0.52);
	.wait(500);
	!patrullarCentro.

/*
+!patrullarCentro: entrada(E) & E = 4 & patrullandoCentro
    <-
	-entrada(E);
	+entrada(0);
	!patrullarCentro.
*/	

+!irAPorPaquete(Position): true
	<-
	.goto(Position);
	-yendoAPorPaquete(_);
	!irAlCentro.