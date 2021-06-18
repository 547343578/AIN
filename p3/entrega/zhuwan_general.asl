
/* Creencia que se dispara cuando se inicia la partida */
+flag (F): team(200) 
	<-
	.register_service("general");
	.get_medics;
	.get_backups;
	.get_fieldops;
	.look_at([256, 0, 256]).


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


/* ESTRATEGIA DE PAQUETES DE SALUD */
/* Recibo solictud de ayuda */
+solicitudSalud(Pos)[source(A)]: not solicitandoAyuda & not eligiendoMedico
	<-
	+solicitandoAyuda;
	?myMedics(M);
	+medicoPOS([]);
	+medicoID([]);
	.send(M, tell, solicitudSalud(Pos));
	.wait(1000);
	!!elegirMedico(Pos).


/* Concateno la posicion y el ID de los medicos que responden */
+respuestaVida(Pos)[source(A)]: solicitandoAyuda & not eligiendoMedico
	<-
	.wait(500);
	?medicoPOS(B);
	.concat(B, [Pos], B1); -+medicoPOS(B1);
	?medicoID(Ag);
	.concat(Ag, [A], Ag1); -+medicoID(Ag1);
	-respuestaVida(Pos).
	

/* PLANES */
/* Plan para elegir el medico más cercano */
+!elegirMedico(Pos): solicitandoAyuda & not eligiendoMedico
	<-
	+eligiendoMedico;
	.wait(500);
	?medicoPOS(Bi);
	?medicoID(Ag);
	.length(Bi, LB);
	if (LB > 0) {
		.medicoMasCerca(Pos,Bi, Medico);  // Guarda en Medico la posicion del medico elegido
		.nth(0, Medico, AAA);
		.nth(AAA, Ag, A);
		.send(A, tell, solicitudAceptada);
		.delete(AAA, Ag, Ag1);
		.send(Ag1, tell, solicitudDenegada);
	}
	-medicoPOS(_);
	-medicoID(_);
	-solicitandoAyuda;
	-eligiendoMedico.
	
/* Plan para cuando no hay ningun médico que pueda ayudar */
+!elegirMedico(Pos): medicoPOS(Bi) & .length(Bi, Len) & Len == 0
	<-
	-solicitandoAyuda.	



/* ESTRATEGIA DE PAQUETES DE MUNICION */
/* Recibo solictud de ayuda */
+solicitudAmmo(Pos)[source(A)]: not solicitandoAmmo & not eligiendoOp
	<-
	.wait(500);
  	+solicitandoAmmo;
  	.get_fieldops;
  	?myFieldops(M);
	+operativoPOS([]);
	+operativoID([]);
	.send(M, tell, solicitudAmmo(Pos));
	.wait(1000);
 	!!elegirOperativo(Pos).


/* Concateno la posicion y el ID de los operativos que responden */
+respuestaAmmo(Pos)[source(A)]: solicitandoAmmo & not eligiendoOp
	<-
	.wait(500);
	?operativoPOS(B);
	.concat(B, [Pos], B1); -+operativoPOS(B1);
	?operativoID(Ag);
	.concat(Ag, [A], Ag1); -+operativoID(Ag1);
	-respuestaAmmo(Pos).
	

/* PLANES */
/* Plan para elegir el operativo más cercano */
+!elegirOperativo(Pos): solicitandoAmmo & not eligiendoOp
	<-
	+eligiendoOp;
	.wait(500);
	?operativoPOS(BiO);
	?operativoID(AgO);
	.length(BiO, LO);
	if (LO > 0) {
		.operativoMasCerca(Pos, BiO, Operativo);  // Guarda en operativo la posicion del operativo elegido
		.nth(0, Operativo, BBB);
		.nth(BBB, AgO, AOO);
		.send(AOO, tell, solicitudAceptada);
		.delete(BBB, AgO, AgO1);
		.send(AgO1, tell, solicitudDenegada);
		-operativoPOS(_);
		-operativoID(_);
	}
	-solicitandoAmmo;
	-eligiendoOp.



/* Plan para cuando no hay ningun operativo que pueda ayudar */
+!elegirOperativo(Pos): operativoPOS(Bi) & .length(Bi, Len) & Len == 0
	<-
	-solicitandoAmmo.
	



/* Recibo solictud de apoyo */
+solicitudEstrategia(Pos)[source(A)]: not solicitandoApoyo & not creandoEquipo
	<-
	+soldadoP([]);
	+soldadoI([]);
	+solicitandoApoyo;
	?myBackups(S);
	.send(S, tell, solicitudEst(Pos));
	.wait(3000);
	!!elegirEquipo(Pos).


/* Concateno la posicipn y el ID de los soldados que responden */
+respuestaEstrategiaS(Pos)[source(A)]: solicitandoApoyo & not creandoEquipo
	<-
	?soldadoP(B);
	.concat(B, [Pos], B1); -+soldadoP(B1);
	?soldadoI(Ag);
	.concat(Ag, [A], Ag1); -+soldadoI(Ag1);
	-respuestaEstrategiaS(Pos).

/* PLANES */
/* Atacar en grupo de 2 */	
+!elegirEquipo(Pos): solicitandoApoyo & not creandoEquipo
	<-
	+creandoEquipo;
	-solicitandoApoyo;
	?soldadoP(Sl);
	?soldadoI(Si);
	
	.length(Sl, L3);
	if (L3 > 1) {
		.agentesMasCercanos2(Pos, Sl, Soldado);  // Guarda en Soldado la posición del medico elegido
		.nth(0, Soldado, Aux1);
		.nth(1, Soldado, Aux2);
		.nth(Aux1, Si, AS);
		.nth(Aux1, Si, BS);
		.send(AS, tell, solicitudAceptadaEst(Pos));
		.send(BS, tell, solicitudAceptadaEst(Pos));
		.delete(Aux1, Si, Ag3);	
		.delete(Aux2, Ag3, Ag4);
		.send(Ag4, tell, solicitudDenegadaEst);
		-soldadoP(_);
		-soldadoI(_);
	}
	
	-creandoEquipo.