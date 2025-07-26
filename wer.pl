% ---------------------------------------------------------------
% Mundo de Wumpus con Lógica de Primer Orden Avanzada
% Implementación mejorada con razonamiento lógico sofisticado
% ---------------------------------------------------------------

:- dynamic([
    wumpus/2, oro/2, hoyo/2, visitado/2, seguro/2,
    posicion_agente/3, tiene_oro/1, tiene_flecha/1,
    no_hedor/2, no_brisa/2, oro_en/2, posible_hoyo/2,
    posible_wumpus/2, puntuacion/1, juego_terminado/1,
    wumpus_muerto/1, ultimo_grito/1, conocido_hoyo/2,
    conocido_wumpus/2, ruta_regreso/1, explorando/1
]).

% ---------------------------------------------------------------
% 1. INICIALIZACIÓN DEL SISTEMA
% ---------------------------------------------------------------

reiniciar :-
    retractall(wumpus(_,_)),
    retractall(oro(_,_)),
    retractall(hoyo(_,_)),
    retractall(visitado(_,_)),
    retractall(seguro(_,_)),
    retractall(posicion_agente(_,_,_)),
    retractall(tiene_oro(_)),
    retractall(tiene_flecha(_)),
    retractall(no_hedor(_,_)),
    retractall(no_brisa(_,_)),
    retractall(oro_en(_,_)),
    retractall(posible_hoyo(_,_)),
    retractall(posible_wumpus(_,_)),
    retractall(puntuacion(_)),
    retractall(juego_terminado(_)),
    retractall(wumpus_muerto(_)),
    retractall(ultimo_grito(_)),
    retractall(conocido_hoyo(_,_)),
    retractall(conocido_wumpus(_,_)),
    retractall(ruta_regreso(_)),
    retractall(explorando(_)).

% ---------------------------------------------------------------
% 2. REPRESENTACIÓN DEL MUNDO
% ---------------------------------------------------------------

casilla(1,1). casilla(1,2). casilla(1,3). casilla(1,4).
casilla(2,1). casilla(2,2). casilla(2,3). casilla(2,4).
casilla(3,1). casilla(3,2). casilla(3,3). casilla(3,4).
casilla(4,1). casilla(4,2). casilla(4,3). casilla(4,4).

configurar_mundo :-
    write('Generando mundo aleatorio...'), nl,
    generar_wumpus,
    generar_oro,
    generar_hoyos, % Using the general random hoyo generation
    write('Mundo generado exitosamente.'), nl.

generar_wumpus :-
    findall([X,Y], (casilla(X,Y), \+ (X=1, Y=1)), Casillas),
    random_member([WX,WY], Casillas),
    assertz(wumpus(WX,WY)),
    format('Wumpus colocado en (~w,~w)~n', [WX,WY]).

generar_oro :-
    findall([X,Y], (casilla(X,Y), \+ (X=1, Y=1), \+ wumpus(X,Y)), Casillas),
    random_member([OX,OY], Casillas),
    assertz(oro(OX,OY)),
    format('Oro colocado en (~w,~w)~n', [OX,OY]).

% This is the standard random hoyo generation, no forced placement.
generar_hoyos :-
    findall([X,Y], (casilla(X,Y), \+ (X=1, Y=1), \+ wumpus(X,Y), \+ oro(X,Y)), Casillas),
    colocar_hoyos(Casillas, 3).

colocar_hoyos(_, 0) :- !.
colocar_hoyos(Casillas, N) :-
    N > 0,
    random_member([X,Y], Casillas),
    % Only assert if it's not already a hole and isn't the initial position
    ( \+ hoyo(X,Y), \+ (X=1, Y=1) ->
        assertz(hoyo(X,Y)),
        format('Hoyo colocado en (~w,~w)~n', [X,Y]),
        N1 is N - 1,
        select([X,Y], Casillas, CasillasRestantes)
    ; % If it's already a hole or initial position, just try again with the same N
        N1 = N,
        select([X,Y], Casillas, CasillasRestantes) % Remove to avoid re-picking
    ),
    colocar_hoyos(CasillasRestantes, N1).

% ---------------------------------------------------------------
% 3. ESTADO INICIAL DEL AGENTE
% ---------------------------------------------------------------

inicializar_agente :-
    assertz(posicion_agente(1, 1, derecha)),
    assertz(tiene_oro(no)),
    assertz(tiene_flecha(si)),
    assertz(visitado(1,1)),
    assertz(seguro(1,1)),
    assertz(puntuacion(0)),
    assertz(juego_terminado(no)),
    assertz(wumpus_muerto(no)),
    assertz(ultimo_grito(no)),
    assertz(ruta_regreso([])),
    assertz(explorando(si)).

% ---------------------------------------------------------------
% 4. SISTEMA DE PERCEPCIÓN MEJORADO
% ---------------------------------------------------------------

percepcion(X, Y, [Hedor, Brisa, Resplandor, Grito]) :-
    (adyacente_wumpus_vivo(X, Y) -> Hedor = hedor ; Hedor = nada),
    (adyacente_hoyo(X, Y) -> Brisa = brisa ; Brisa = nada),
    (oro(X, Y) -> Resplandor = resplandor ; Resplandor = nada),
    (ultimo_grito(si) -> Grito = grito ; Grito = nada).

adyacente_wumpus_vivo(X, Y) :-
    wumpus_muerto(no),
    wumpus(WX, WY),
    adyacente(X, Y, WX, WY).

adyacente_hoyo(X, Y) :-
    hoyo(HX, HY),
    adyacente(X, Y, HX, HY).

adyacente(X1, Y1, X2, Y2) :-
    (   X2 is X1 + 1, Y2 = Y1
    ;   X2 is X1 - 1, Y2 = Y1
    ;   X2 = X1, Y2 is Y1 + 1
    ;   X2 = X1, Y2 is Y1 - 1
    ).

mostrar_percepcion(X, Y) :-
    percepcion(X, Y, Percepcion),
    format('Percepción en (~w,~w): ~w~n', [X, Y, Percepcion]).

% ---------------------------------------------------------------
% 5. MOTOR DE INFERENCIA CON LÓGICA DE PRIMER ORDEN
% ---------------------------------------------------------------

actualizar_conocimiento(X, Y, [Hedor, Brisa, Resplandor, Grito]) :-
    format('Analizando percepción en (~w,~w): [~w,~w,~w,~w]~n', [X,Y,Hedor,Brisa,Resplandor,Grito]),

    (\+ visitado(X,Y) -> assertz(visitado(X,Y)) ; true),

    procesar_hedor(X, Y, Hedor),
    procesar_brisa(X, Y, Brisa),
    procesar_resplandor(X, Y, Resplandor),
    procesar_grito(Grito),

    inferir_conocimiento_avanzado(X, Y, Hedor, Brisa),

    determinar_casillas_seguras,

    mostrar_inferencias(X, Y).

procesar_hedor(X, Y, nada) :-
    assertz(no_hedor(X,Y)),
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B)), Adyacentes),
    marcar_sin_wumpus(Adyacentes),
    write('    -> Sin hedor: casillas adyacentes libres de Wumpus'), nl.

procesar_hedor(X, Y, hedor) :-
    write('    -> Hedor detectado: Wumpus en casilla adyacente'), nl,
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B), \+ visitado(A,B)), Candidatos),
    marcar_candidatos_wumpus(Candidatos).

procesar_brisa(X, Y, nada) :-
    assertz(no_brisa(X,Y)),
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B)), Adyacentes),
    marcar_sin_hoyo(Adyacentes),
    write('    -> Sin brisa: casillas adyacentes libres de hoyos'), nl.

procesar_brisa(X, Y, brisa) :-
    write('    -> Brisa detectada: Hoyo en casilla adyacente'), nl,
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B), \+ visitado(A,B)), Candidatos),
    marcar_candidatos_hoyo(Candidatos).

procesar_resplandor(X, Y, resplandor) :-
    assertz(oro_en(X,Y)),
    write('    -> ¡ORO ENCONTRADO!'), nl.

procesar_resplandor(_, _, nada).

procesar_grito(grito) :-
    retract(wumpus_muerto(no)),
    assertz(wumpus_muerto(si)),
    retract(ultimo_grito(si)),
    assertz(ultimo_grito(no)),
    write('    -> Wumpus eliminado: Área expandida como segura'), nl,
    retractall(posible_wumpus(_,_)).

procesar_grito(nada).

inferir_conocimiento_avanzado(X, Y, nada, nada) :-
    write('    -> Inferencia: Todas las casillas adyacentes son SEGURAS'), nl,
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B)), Adyacentes),
    marcar_todas_seguras(Adyacentes).

inferir_conocimiento_avanzado(X, Y, hedor, nada) :-
    write('    -> Inferencia: Wumpus adyacente, pero sin hoyos'), nl,
    aplicar_eliminacion_wumpus(X, Y).

inferir_conocimiento_avanzado(X, Y, nada, brisa) :-
    write('    -> Inferencia: Hoyo adyacente, pero sin Wumpus'), nl,
    aplicar_eliminacion_hoyo(X, Y).

inferir_conocimiento_avanzado(_X, _Y, hedor, brisa) :-
    write('    -> Inferencia: Wumpus Y hoyo en casillas adyacentes'), nl.

aplicar_eliminacion_wumpus(X, Y) :-
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B)), Adyacentes),
    filtrar_candidatos_wumpus(Adyacentes, CandidatosFiltrados),
    (CandidatosFiltrados = [[WX,WY]] ->
        (format('    -> WUMPUS LOCALIZADO en (~w,~w) por eliminación~n', [WX,WY]),
         assertz(conocido_wumpus(WX,WY)))
    ; marcar_candidatos_wumpus(CandidatosFiltrados)).

aplicar_eliminacion_hoyo(X, Y) :-
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B)), Adyacentes),
    filtrar_candidatos_hoyo(Adyacentes, CandidatosFiltrados),
    (CandidatosFiltrados = [[HX,HY]] ->
        (format('    -> HOYO LOCALIZADO en (~w,~w) por eliminación~n', [HX,HY]),
         assertz(conocido_hoyo(HX,HY)))
    ; marcar_candidatos_hoyo(CandidatosFiltrados)).

filtrar_candidatos_wumpus([], []).
filtrar_candidatos_wumpus([[X,Y]|Resto], Filtrados) :-
    (visitado(X,Y) ; no_hedor_en_adyacente(X,Y)),
    !,
    filtrar_candidatos_wumpus(Resto, Filtrados).
filtrar_candidatos_wumpus([[X,Y]|Resto], [[X,Y]|Filtrados]) :-
    \+ visitado(X,Y),
    \+ no_hedor_en_adyacente(X,Y),
    filtrar_candidatos_wumpus(Resto, Filtrados).

filtrar_candidatos_hoyo([], []).
filtrar_candidatos_hoyo([[X,Y]|Resto], Filtrados) :-
    (visitado(X,Y) ; no_brisa_en_adyacente(X,Y)),
    !,
    filtrar_candidatos_hoyo(Resto, Filtrados).
filtrar_candidatos_hoyo([[X,Y]|Resto], [[X,Y]|Filtrados]) :-
    \+ visitado(X,Y),
    \+ no_brisa_en_adyacente(X,Y),
    filtrar_candidatos_hoyo(Resto, Filtrados).

no_hedor_en_adyacente(X, Y) :-
    adyacente(X, Y, AX, AY),
    no_hedor(AX, AY).

no_brisa_en_adyacente(X, Y) :-
    adyacente(X, Y, AX, AY),
    no_brisa(AX, AY).

determinar_casillas_seguras :-
    casilla(X, Y),
    \+ visitado(X, Y),
    \+ seguro(X, Y),
    es_casilla_segura_por_logica(X, Y),
    assertz(seguro(X, Y)),
    format('    -> Casilla (~w,~w) determinada como SEGURA por lógica~n', [X, Y]),
    fail.
determinar_casillas_seguras.

es_casilla_segura_por_logica(X, Y) :-
    \+ posible_wumpus(X, Y),
    \+ posible_hoyo(X, Y),
    \+ conocido_wumpus(X, Y),
    \+ conocido_hoyo(X, Y).

marcar_sin_wumpus([]).
marcar_sin_wumpus([[X,Y]|Resto]) :-
    retractall(posible_wumpus(X,Y)),
    marcar_sin_wumpus(Resto).

marcar_sin_hoyo([]).
marcar_sin_hoyo([[X,Y]|Resto]) :-
    retractall(posible_hoyo(X,Y)),
    marcar_sin_hoyo(Resto).

marcar_candidatos_wumpus([]).
marcar_candidatos_wumpus([[X,Y]|Resto]) :-
    (\+ posible_wumpus(X,Y), \+ visitado(X,Y) -> assertz(posible_wumpus(X,Y)) ; true),
    marcar_candidatos_wumpus(Resto).

marcar_candidatos_hoyo([]).
marcar_candidatos_hoyo([[X,Y]|Resto]) :-
    (\+ posible_hoyo(X,Y), \+ visitado(X,Y) -> assertz(posible_hoyo(X,Y)) ; true),
    marcar_candidatos_hoyo(Resto).

marcar_todas_seguras([]).
marcar_todas_seguras([[X,Y]|Resto]) :-
    (casilla(X,Y), \+ visitado(X,Y) -> assertz(seguro(X,Y)) ; true),
    marcar_todas_seguras(Resto).

mostrar_inferencias(X, Y) :-
    findall([A,B], (adyacente(X,Y,A,B), seguro(A,B), \+ visitado(A,B)), Seguras),
    (Seguras \= [] ->
        (write('    -> Casillas seguras para explorar: '), write(Seguras), nl) ; true).

% ---------------------------------------------------------------
% 6. SISTEMA DE DECISIÓN MEJORADO CON RETROCESO
% ---------------------------------------------------------------

explorar :-
    juego_terminado(Estado),
    Estado \= no,
    write('Juego terminado: '), write(Estado), nl,
    mostrar_puntuacion, !.

explorar :-
    verificar_victoria,
    juego_terminado(victoria), !.

explorar :-
    posicion_agente(X,Y,_),
    oro_en(X,Y),
    write('¡Oro encontrado! Recogiendo...'), nl,
    agarrar_oro,
    planificar_regreso, !.

explorar :-
    posicion_agente(X,Y,Orientacion),
    mostrar_percepcion(X, Y),
    percepcion(X, Y, Percepcion),
    actualizar_conocimiento(X, Y, Percepcion),
    decidir_siguiente_accion(X, Y, Orientacion).

decidir_siguiente_accion(X, Y, Orientacion) :-
    (encontrar_casilla_segura_objetivo(X, Y, Orientacion, ObjetivoX, ObjetivoY) ->
        (format('Objetivo: casilla segura (~w,~w)~n', [ObjetivoX, ObjetivoY]),
         navegar_hacia(X, Y, Orientacion, ObjetivoX, ObjetivoY))
    ; (write('No hay casillas seguras disponibles. Evaluando retroceso...'), nl,
        considerar_retroceso(X, Y, Orientacion))
    ).

encontrar_casilla_segura_objetivo(X, Y, _, ObjetivoX, ObjetivoY) :-
    seguro(ObjetivoX, ObjetivoY),
    \+ visitado(ObjetivoX, ObjetivoY),
    DistanciaActual is abs(X - ObjetivoX) + abs(Y - ObjetivoY),
    \+ (seguro(OX, OY), \+ visitado(OX, OY),
        DistanciaOtra is abs(X - OX) + abs(Y - OY),
        DistanciaOtra < DistanciaActual).

navegar_hacia(X, Y, Orientacion, ObjetivoX, ObjetivoY) :-
    (frente(X, Y, Orientacion, ObjetivoX, ObjetivoY) ->
        (realizar_accion(avanzar), explorar)
    ; (determinar_orientacion_objetivo(X, Y, ObjetivoX, ObjetivoY, OrientacionObjetivo),
        girar_hacia_orientacion(Orientacion, OrientacionObjetivo),
        explorar)
    ).

determinar_orientacion_objetivo(X, _Y, ObjetivoX, _ObjetivoY, derecha) :- ObjetivoX > X, !.
determinar_orientacion_objetivo(X, _Y, ObjetivoX, _ObjetivoY, izquierda) :- ObjetivoX < X, !.
determinar_orientacion_objetivo(_X, Y, _ObjetivoX, ObjetivoY, arriba) :- ObjetivoY > Y, !.
determinar_orientacion_objetivo(_X, Y, _ObjetivoX, ObjetivoY, abajo) :- ObjetivoY < Y.

girar_hacia_orientacion(Orientacion, Orientacion) :- !.
girar_hacia_orientacion(OrientacionActual, OrientacionObjetivo) :-
    nueva_orientacion(OrientacionActual, derecha, NuevaOrientacion),
    (NuevaOrientacion = OrientacionObjetivo ->
        realizar_accion(girar_derecha)
    ; realizar_accion(girar_izquierda)).

considerar_retroceso(X, Y, Orientacion) :-
    ruta_regreso(Ruta),
    (Ruta \= [] ->
        (write('Iniciando retroceso por ruta segura...'), nl,
         retroceder_por_ruta(Ruta))
    ; (write('No hay ruta de retroceso. Explorando con precaución...'), nl,
        explorar_con_precaucion(X, Y, Orientacion))
    ).

retroceder_por_ruta([UltimaPosicion|RestoRuta]) :-
    UltimaPosicion = [X, Y],
    posicion_agente(ActualX, ActualY, Orientacion),
    format('Retrocediendo hacia (~w,~w)~n', [X, Y]),
    navegar_hacia(ActualX, ActualY, Orientacion, X, Y),
    retract(ruta_regreso(_)),
    assertz(ruta_regreso(RestoRuta)).

explorar_con_precaucion(X, Y, Orientacion) :-
    write('Modo exploración cautelosa activado...'), nl,
    findall([A,B], (adyacente(X,Y,A,B), casilla(A,B), \+ visitado(A,B)), Candidatos),
    (Candidatos \= [] ->
        (random_member([CX, CY], Candidatos),
         format('Explorando cautelosamente hacia (~w,~w)~n', [CX, CY]),
         navegar_hacia(X, Y, Orientacion, CX, CY))
    ; (write('No hay más casillas por explorar. Terminando...'), nl,
        assertz(juego_terminado(sin_opciones)))
    ).

planificar_regreso :-
    write('Planificando regreso a (1,1) con el oro...'), nl,
    retract(explorando(si)),
    assertz(explorando(no)),
    regresar_a_inicio.

regresar_a_inicio :-
    posicion_agente(1, 1, _),
    verificar_victoria, !.

regresar_a_inicio :-
    posicion_agente(X, Y, Orientacion),
    (X > 1 ->
        navegar_hacia(X, Y, Orientacion, X-1, Y)
    ; Y > 1 ->
        navegar_hacia(X, Y, Orientacion, X, Y-1)
    ; true),
    regresar_a_inicio.

% ---------------------------------------------------------------
% 7. VERIFICACIÓN DE CONDICIONES
% ---------------------------------------------------------------

verificar_muerte(X, Y) :-
    (hoyo(X, Y) ->
        (write('¡AGENTE CAYÓ EN UN HOYO! Juego terminado.'), nl,
         modificar_puntuacion(-1000),
         retract(juego_terminado(no)),
         assertz(juego_terminado(derrota_hoyo)))
    ; true),

    (wumpus(X, Y), wumpus_muerto(no) ->
        (write('¡EL WUMPUS DEVORÓ AL AGENTE! Juego terminado.'), nl,
         modificar_puntuacion(-1000),
         retract(juego_terminado(no)),
         assertz(juego_terminado(derrota_wumpus)))
    ; true).

verificar_victoria :-
    posicion_agente(1, 1, _),
    tiene_oro(si),
    write('¡VICTORIA! El agente regresó con el oro.'), nl,
    modificar_puntuacion(1000),
    retract(juego_terminado(no)),
    assertz(juego_terminado(victoria)).

% ---------------------------------------------------------------
% 8. SISTEMA DE PUNTUACIÓN Y NAVEGACIÓN
% ---------------------------------------------------------------

modificar_puntuacion(Cambio) :-
    retract(puntuacion(Actual)),
    Nueva is Actual + Cambio,
    assertz(puntuacion(Nueva)),
    format('Puntuación: ~w (~w)~n', [Nueva, Cambio]).

mostrar_puntuacion :-
    puntuacion(P),
    format('Puntuación actual: ~w~n', [P]).

frente(X, Y, derecha, X1, Y) :- X1 is X+1, casilla(X1,Y).
frente(X, Y, izquierda, X1, Y) :- X1 is X-1, casilla(X1,Y).
frente(X, Y, arriba, X, Y1) :- Y1 is Y+1, casilla(X,Y1).
frente(X, Y, abajo, X, Y1) :- Y1 is Y-1, casilla(X,Y1).

nueva_orientacion(derecha,derecha,abajo).
nueva_orientacion(derecha,izquierda,arriba).
nueva_orientacion(izquierda,derecha,arriba).
nueva_orientacion(izquierda,izquierda,abajo).
nueva_orientacion(arriba,derecha,derecha).
nueva_orientacion(arriba,izquierda,izquierda).
nueva_orientacion(abajo,derecha,izquierda).
nueva_orientacion(abajo,izquierda,derecha).

% ---------------------------------------------------------------
% 9. ACCIONES DEL AGENTE
% ---------------------------------------------------------------

realizar_accion(avanzar) :-
    posicion_agente(X,Y,Orientacion),
    (frente(X,Y,Orientacion,NX,NY) ->
        (retract(posicion_agente(X,Y,Orientacion)),
         assertz(posicion_agente(NX,NY,Orientacion)),
         modificar_puntuacion(-1),
         ruta_regreso(Ruta),
         retract(ruta_regreso(Ruta)),
         assertz(ruta_regreso([[X,Y]|Ruta])),
         format('Avanzando a (~w,~w)~n', [NX,NY]),
         verificar_muerte(NX,NY))
    ; (write('¡GOLPE! No se puede avanzar más.'), nl,
       modificar_puntuacion(-1))).

realizar_accion(girar_derecha) :-
    posicion_agente(X,Y,Orientacion),
    nueva_orientacion(Orientacion,derecha,Nueva),
    retract(posicion_agente(X,Y,Orientacion)),
    assertz(posicion_agente(X,Y,Nueva)),
    modificar_puntuacion(-1),
    format('Girando a derecha. Nueva orientación: ~w~n', [Nueva]).

realizar_accion(girar_izquierda) :-
    posicion_agente(X,Y,Orientacion),
    nueva_orientacion(Orientacion,izquierda,Nueva),
    retract(posicion_agente(X,Y,Orientacion)),
    assertz(posicion_agente(X,Y,Nueva)),
    modificar_puntuacion(-1),
    format('Girando a izquierda. Nueva orientación: ~w~n', [Nueva]).

realizar_accion(disparar) :-
    tiene_flecha(si),
    posicion_agente(X,Y,Orientacion),
    retract(tiene_flecha(si)),
    assertz(tiene_flecha(no)),
    modificar_puntuacion(-10),
    (wumpus_en_linea(X,Y,Orientacion) ->
        (retract(wumpus_muerto(no)),
         assertz(wumpus_muerto(si)),
         retract(ultimo_grito(no)),
         assertz(ultimo_grito(si)),
         write('¡GRITO! El Wumpus ha sido eliminado.'), nl)
    ; write('Flecha perdida en la oscuridad.'), nl).

realizar_accion(disparar) :-
    tiene_flecha(no),
    write('No tienes flecha para disparar.'), nl.

agarrar_oro :-
    posicion_agente(X,Y,_),
    oro(X,Y),
    retract(tiene_oro(no)),
    assertz(tiene_oro(si)),
    retract(oro(X,Y)),
    write('Oro recogido.'), nl.

wumpus_en_linea(X,Y,derecha) :- wumpus(WX,Y), WX > X.
wumpus_en_linea(X,Y,izquierda) :- wumpus(WX,Y), WX < X.
wumpus_en_linea(X,Y,arriba) :- wumpus(X,WY), WY > Y.
wumpus_en_linea(X,Y,abajo) :- wumpus(X,WY), WY < Y.

% ---------------------------------------------------------------
% 10. SISTEMA DE VISUALIZACIÓN Y DEPURACIÓN AVANZADO
% ---------------------------------------------------------------

mostrar_mundo_completo :-
    write('=== ESTADO COMPLETO DEL MUNDO ==='), nl,
    mostrar_tablero_visual,
    nl,
    mostrar_estado_agente,
    nl,
    mostrar_conocimiento_agente.

mostrar_tablero_visual :-
    write('Tablero (W=Wumpus, G=Oro, H=Hoyo, A=Agente):'), nl,
    mostrar_fila(4),
    mostrar_fila(3),
    mostrar_fila(2),
    mostrar_fila(1),
    write('  1 2 3 4'), nl.

mostrar_fila(Y) :-
    write(Y), write(' '),
    mostrar_casilla(1, Y), write(' '),
    mostrar_casilla(2, Y), write(' '),
    mostrar_casilla(3, Y), write(' '),
    mostrar_casilla(4, Y), nl.

mostrar_casilla(X, Y) :-
    (posicion_agente(X, Y, _) -> write('A')
    ; wumpus(X, Y) -> write('W')
    ; oro(X, Y) -> write('G')
    ; hoyo(X, Y) -> write('H')
    ; write('.')).

mostrar_estado_agente :-
    write('=== ESTADO DEL AGENTE ==='), nl,
    posicion_agente(X, Y, Orientacion),
    format('Posición: (~w,~w) mirando ~w~n', [X, Y, Orientacion]),
    tiene_oro(Oro),
    format('Tiene oro: ~w~n', [Oro]),
    tiene_flecha(Flecha),
    format('Tiene flecha: ~w~n', [Flecha]),
    puntuacion(P),
    format('Puntuación: ~w~n', [P]).

mostrar_conocimiento_agente :-
    write('=== CONOCIMIENTO DEL AGENTE ==='), nl,
    write('Casillas visitadas: '),
    findall([X,Y], visitado(X,Y), Visitadas),
    write(Visitadas), nl,
    write('Casillas seguras: '),
    findall([X,Y], seguro(X,Y), Seguras),
    write(Seguras), nl,
    write('Posibles Wumpus: '),
    findall([X,Y], posible_wumpus(X,Y), PosiblesW),
    write(PosiblesW), nl,
    write('Posibles hoyos: '),
    findall([X,Y], posible_hoyo(X,Y), PosiblesH),
    write(PosiblesH), nl,
    (conocido_wumpus(WX, WY) ->
        format('Wumpus localizado en: (~w,~w)~n', [WX, WY]) ; true),
    (conocido_hoyo(HX, HY) ->
        format('Hoyo localizado en: (~w,~w)~n', [HX, HY]) ; true).

mostrar_mapa_conocimiento :-
    write('=== MAPA DE CONOCIMIENTO ==='), nl,
    write('V=Visitado, S=Seguro, W?=Posible Wumpus, H?=Posible Hoyo'), nl,
    mostrar_mapa_fila(4),
    mostrar_mapa_fila(3),
    mostrar_mapa_fila(2),
    mostrar_mapa_fila(1),
    write('    1    2    3    4'), nl.

mostrar_mapa_fila(Y) :-
    write(Y), write(' '),
    mostrar_conocimiento_casilla(1, Y), write(' '),
    mostrar_conocimiento_casilla(2, Y), write(' '),
    mostrar_conocimiento_casilla(3, Y), write(' '),
    mostrar_conocimiento_casilla(4, Y), nl.

mostrar_conocimiento_casilla(X, Y) :-
    (visitado(X, Y) -> write('V') ; write('.')),
    (seguro(X, Y) -> write('S') ; write('.')),
    (posible_wumpus(X, Y) -> write('W') ; write('.')),
    (posible_hoyo(X, Y) -> write('H') ; write('.')).

% ---------------------------------------------------------------
% 11. SISTEMA DE ANÁLISIS DE SITUACIONES CRÍTICAS
% ---------------------------------------------------------------

analizar_situacion_critica :-
    posicion_agente(X, Y, _),
    percepcion(X, Y, [Hedor, Brisa, _, _]),
    (Hedor = hedor, Brisa = brisa ->
        (write('¡SITUACIÓN CRÍTICA! Wumpus Y hoyo detectados.'), nl,
         analizar_escape_critico(X, Y))
    ; Hedor = hedor ->
        (write('¡PELIGRO! Wumpus cercano.'), nl,
         considerar_disparo(X, Y))
    ; Brisa = brisa ->
        (write('¡PRECAUCIÓN! Hoyo cercano.'), nl,
         planificar_movimiento_seguro(X, Y))
    ; true).

analizar_escape_critico(X_curr, Y_curr) :-
    write('Analizando opciones de escape...'), nl,
    findall([A,B], (adyacente(X_curr,Y_curr,A,B), visitado(A,B)), CasillasSeguras),
    (CasillasSeguras \= [] ->
        (write('Ruta de escape disponible: '), write(CasillasSeguras), nl,
         CasillasSeguras = [[EX, EY]|_],
         format('Escapando hacia (~w,~w)~n', [EX, EY]))
    ; (write('¡SIN RUTA DE ESCAPE! Evaluando disparo de emergencia...'), nl,
        considerar_disparo_emergencia(X_curr, Y_curr))).

considerar_disparo(X, Y) :-
    tiene_flecha(si),
    posicion_agente(X, Y, Orientacion),
    (wumpus_en_linea(X, Y, Orientacion) ->
        (write('Wumpus en línea de fuego. ¿Disparar? Evaluando...'), nl,
         realizar_accion(disparar))
    ; write('Wumpus no está en línea de fuego.'), nl).

considerar_disparo_emergencia(_X, _Y) :-
    tiene_flecha(si),
    write('Disparo de emergencia activado.'), nl,
    realizar_accion(disparar).

considerar_disparo_emergencia(_X, _Y) :-
    tiene_flecha(no),
    write('Sin flecha para disparo de emergencia. Situación desesperada.'), nl.

planificar_movimiento_seguro(X, Y) :-
    findall([A,B], (adyacente(X,Y,A,B), seguro(A,B), \+ visitado(A,B)), OpcionesSeguras),
    (OpcionesSeguras \= [] ->
        (write('Movimiento seguro disponible: '), write(OpcionesSeguras), nl)
    ; (write('No hay movimientos seguros evidentes. Retrocediendo...'), nl,
        considerar_retroceso(X, Y, _))).

% ---------------------------------------------------------------
% 12. ESTRATEGIAS AVANZADAS DE EXPLORACIÓN
% ---------------------------------------------------------------

explorar_sistematicamente :-
    write('Iniciando exploración sistemática...'), nl,
    explorar_por_filas.

explorar_por_filas :-
    member(Y, [1,2,3,4]),
    explorar_fila(Y),
    fail.
explorar_por_filas.

explorar_fila(Y) :-
    casilla(X, Y),
    seguro(X, Y),
    \+ visitado(X, Y),
    format('Explorando casilla (~w,~w) de fila ~w~n', [X, Y, Y]),
    navegar_hacia_casilla(X, Y),
    fail.
explorar_fila(_).

navegar_hacia_casilla(ObjetivoX, ObjetivoY) :-
    posicion_agente(X, Y, Orientacion),
    navegar_hacia(X, Y, Orientacion, ObjetivoX, ObjetivoY).

busqueda_profundidad_limitada(Profundidad) :-
    posicion_agente(X, Y, _),
    buscar_oro_profundidad(X, Y, Profundidad, []).

buscar_oro_profundidad(_X, _Y, 0, _) :- !.
buscar_oro_profundidad(X, Y, _Prof, _Visitados) :-
    oro_en(X, Y),
    write('¡Oro encontrado en búsqueda por profundidad!'), nl, !.

buscar_oro_profundidad(X, Y, Prof, Visitados) :-
    Prof > 0,
    Prof1 is Prof - 1,
    adyacente(X, Y, NX, NY),
    seguro(NX, NY),
    \+ member([NX, NY], Visitados),
    buscar_oro_profundidad(NX, NY, Prof1, [[X,Y]|Visitados]).

% ---------------------------------------------------------------
% 13. INICIALIZACIÓN Y COMANDOS PRINCIPALES
% ---------------------------------------------------------------

iniciar :-
    reiniciar,
    configurar_mundo,
    inicializar_agente,
    write('=== MUNDO DE WUMPUS - VERSIÓN AVANZADA ==='), nl,
    write('Con Lógica de Primer Orden y Razonamiento Sofisticado'), nl,
    mostrar_puntuacion,
    mostrar_mundo_completo,
    nl,
    write('Iniciando exploración inteligente...'), nl,
    explorar.

paso :-
    juego_terminado(Estado),
    Estado \= no,
    write('Juego terminado: '), write(Estado), nl, !.

paso :-
    posicion_agente(X,Y,Orientacion),
    write('--- PASO DE EXPLORACIÓN ---'), nl,
    mostrar_percepcion(X, Y),
    percepcion(X, Y, Percepcion),
    actualizar_conocimiento(X, Y, Percepcion),
    analizar_situacion_critica,
    decidir_siguiente_accion(X, Y, Orientacion),
    nl,
    mostrar_mapa_conocimiento.

ayuda :-
    write('=== COMANDOS DISPONIBLES ==='), nl,
    write('iniciar.             - Inicia un nuevo juego'), nl,
    write('paso.                - Ejecuta un paso de exploración'), nl,
    write('mostrar_mundo_completo. - Muestra estado completo'), nl,
    write('mostrar_mapa_conocimiento. - Muestra mapa de conocimiento'), nl,
    write('mostrar_puntuacion.  - Muestra puntuación actual'), nl,
    write('analizar_situacion_critica. - Analiza situación actual'), nl,
    write('ayuda.               - Muestra esta ayuda'), nl.

% ---------------------------------------------------------------
% 14. PREDICADOS DE UTILIDAD FINAL
% ---------------------------------------------------------------

verificar_consistencia :-
    write('Verificando consistencia del conocimiento...'), nl,
    (inconsistencia_detectada ->
        write('¡INCONSISTENCIA DETECTADA EN LA BASE DE CONOCIMIENTO!'), nl
    ; write('Base de conocimiento consistente.'), nl).

inconsistencia_detectada :-
    posible_wumpus(X, Y),
    seguro(X, Y),
    format('Inconsistencia: (~w,~w) marcada como posible Wumpus Y segura~n', [X, Y]).

inconsistencia_detectada :-
    posible_hoyo(X, Y),
    seguro(X, Y),
    format('Inconsistencia: (~w,~w) marcada como posible hoyo Y segura~n', [X, Y]).

mostrar_estadisticas :-
    write('=== ESTADÍSTICAS DEL JUEGO ==='), nl,
    findall(_, visitado(_,_), Visitadas),
    length(Visitadas, NumVisitadas),
    format('Casillas visitadas: ~w/16~n', [NumVisitadas]),
    findall(_, seguro(_,_), Seguras),
    length(Seguras, NumSeguras),
    format('Casillas conocidas como seguras: ~w~n', [NumSeguras]),
    findall(_, posible_wumpus(_,_), PosiblesW),
    length(PosiblesW, NumPosiblesW),
    format('Casillas con posible Wumpus: ~w~n', [NumPosiblesW]),
    findall(_, posible_hoyo(_,_), PosiblesH),
    length(PosiblesH, NumPosiblesH),
    format('Casillas con posible hoyo: ~w~n', [NumPosiblesH]),
    puntuacion(P),
    format('Puntuación actual: ~w~n', [P]).

simular_ejemplo_libro :-
    write('Simulando ejemplo del libro de IA...'), nl,
    reiniciar,
    assertz(wumpus(1,3)),
    assertz(oro(2,3)),
    assertz(hoyo(3,1)),
    assertz(hoyo(3,3)),
    assertz(hoyo(4,4)),
    inicializar_agente,
    write('Mundo configurado según ejemplo del libro.'), nl,
    mostrar_mundo_completo,
    explorar.
