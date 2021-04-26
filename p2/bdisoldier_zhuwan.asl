Estrategia: 

Agente agresivo que va al centro de mapa desde principio, una vez ya esta en el centro
se queda alli girando y vigilando a los enemigo que vienen. Si ve a un enemigo que tiene
menor health que el, le persigue y le dispara, en el caso contrario, es decir si ha visto
a un enemigo que tiene el health superior que el, se va al centro otra vez y se queda 
alli girando. Ademas, recoge todos los paquetes que pueda, para siempre tener un health 
y ammo conveniente.


/* CREENCIAS INICIALES */

centro([130, 0, 130]). 		


/* CREENCIAS A DISPARAR */

+flag(F): team(200)
    <-
	!irAlCentro.


+friends_in_fov(ID, Type, Angle, Distance, Health, Position): yendoAlCentro
    <-
	-yendoAlCentro;
	!irAlCentro.


+friends_in_fov(ID, Type, Angle, Distance, Health, Position): health(H) & H >= Health & ammo(A) & A > 0
    <-
	.print("Disparo");
	-girandoCentro;
	.shoot(9, Position);
	.look_at(Position);
	+enemigo(Position);
	.print(ammo(A));
	.print(Health);
	.print(health(H));
	.goto(Position).
	

+friends_in_fov(ID, Type, Angle, Distance, Health, Position): health(H) & (H < Health | ammo(A) & A <= 0)
    <-
	.shoot(3,Position);
	!irAlCentro.
	
	
+packs_in_fov(ID, Type, Angle, Distance, Health, Position): Type = 1001 & (not yendoAPorPaquete(1001)) & health(H) & H < 100
	<-
	-girandoCentro;
	+yendoAPorPaquete(1001);
	!irAPorPaquete(Position).
	
	
+packs_in_fov(ID, Type, Angle, Distance, Health, Position): Type = 1002 & (not yendoAPorPaquete(_)) & ammo(A) & A < 100
	<-
	-girandoCentro;
	+yendoAPorPaquete(1002);
	!irAPorPaquete(Position).


+target_reached(T): centro(C) & C==T
    <-
	-yendoAlCentro;
	+girandoCentro;
	!girarCentro;
	-target_reached(T).

+target_reached(T): paquete(P) & P==T
    <-
	-paquete(P);
	!irAlCentro;
	-target_reached(T).


+target_reached(T): enemigo(P) & P==T
	<-
	.print("Veo a un enemigo");
	-enemigo(Position);
	-target_reached(T).
	



/* PLANES */

+!irAlCentro
	<-
	+yendoAlCentro;
	?centro(Pos);
	.goto(Pos).


+!girarCentro: girandoCentro
    <-
	.turn(0.52);
	.wait(1000);
	!girarCentro.
	
	
+!girarCentro.
	/*
	<-
	+girandoCentro;
	!girarCentro.
	*/


+!irAPorPaquete(Position): true
	<-
	+paquete(Position);
	-yendoAPorPaquete(_);
	.goto(Position).