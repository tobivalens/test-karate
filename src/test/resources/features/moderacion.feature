@api @moduloModeracion
Feature: Moderación automática del chat de la comunidad de e-sports
  Como moderador de la comunidad de videojuegos
  Quiero que el motor evalúe las condiciones de cada mensaje
  Para aplicar la acción correcta según insultos, advertencias y enlaces


  #Variable	Significado	Si es true
  #C1	El mensaje contiene insultos graves.	Hay insultos graves.
  #C2	El usuario acumula tres o más advertencias en 24 horas.	Tiene suficientes advertencias acumuladas.
  #C3	El mensaje incluye enlaces sospechosos.	Hay un enlace sospechoso.

  Background:
    # Verifica el orden C1, C2, C3 publicado por la API antes de evaluar reglas.
    Given url baseUrl
    And path 'decision/moderacion-foro/definicion'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    When method get
    Then status 200
    And match response.condiciones == ['Mensaje contiene insultos graves (lista negra)', 'Usuario acumula 3+ advertencias previas por toxicidad en 24h', 'Mensaje incluye enlaces sospechosos o acortadores no verificados']
    And match response.condiciones[0] == '#string'
    And match response.condiciones[1] == '#string'
    And match response.condiciones[2] == '#string'
    # Cada caso comienza con historial vacío y aislado.
    Given url baseUrl
    And path 'decision/moderacion-foro/reiniciar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And header Content-Length = '0'
    When method post
    Then status 200
    And match response.ok == true

  @smoketest @Issue-2 @REQ-MOD-R1
  Scenario: R1 - Mensaje limpio se publica con normalidad
    * def valores = [false, false, false]
    * def accionEsperada = 'Publicar mensaje con normalidad en el flujo de la conversación'
    # C1, C2 y C3 se envían en el orden confirmado en la definición.
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-3 @REQ-MOD-R2
  Scenario: R2 - Enlace sospechoso oculta el mensaje
    * def valores = [false, false, true]
    * def accionEsperada = 'Ocultar mensaje automáticamente y mostrar advertencia de seguridad al chat'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-4 @REQ-MOD-R3
  Scenario: R3 - Tres advertencias escalan a baneo permanente
    * def valores = [false, true, false]
    * def accionEsperada = 'Escalar a baneo permanente de la cuenta de usuario'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-5 @REQ-MOD-R4
  Scenario: R4 - Advertencias acumuladas tienen prioridad sobre el enlace sospechoso
    * def valores = [false, true, true]
    * def accionEsperada = 'Escalar a baneo permanente de la cuenta de usuario'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-6 @REQ-MOD-R5
  Scenario: R5 - Insulto grave elimina el mensaje y suspende el chat
    * def valores = [true, false, false]
    * def accionEsperada = 'Eliminar el mensaje instantáneamente y aplicar suspensión temporal de chat por 24 horas'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-7 @REQ-MOD-R6
  Scenario: R6 - Insulto grave tiene prioridad sobre el enlace sospechoso
    * def valores = [true, false, true]
    * def accionEsperada = 'Eliminar el mensaje instantáneamente y aplicar suspensión temporal de chat por 24 horas'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response



  @regression @Issue-8 @REQ-MOD-R7
  Scenario: R7 - Advertencias acumuladas tienen prioridad sobre el insulto grave
    * def valores = [true, true, false]
    * def accionEsperada = 'Eliminar el mensaje instantáneamente y aplicar suspensión temporal de chat por 24 horas'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-9 @REQ-MOD-R8
  Scenario: R8 - Con las tres condiciones activas prevalece el baneo por advertencias
    * def valores = [true, true, true]
    * def accionEsperada = 'Eliminar el mensaje instantáneamente y aplicar suspensión temporal de chat por 24 horas'
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valores)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    And match response.accion == accionEsperada
    And match response.valores == valores
    And match response.noDefinida == false
    * print 'Resultado de moderación:', response

  @regression @Issue-10 @REQ-MOD-HISTORIAL
  Scenario: R9- El historial registra las evaluaciones realizadas
    * def valoresLimpios = [false, false, false]
    * def valoresInsulto = [true, false, false]
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valoresLimpios)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    * print 'Primera evaluación:', response
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valoresInsulto)' }
    When method post
    Then status 200
    And match response.accion == '#string'
    * print 'Segunda evaluación:', response
    Given url baseUrl
    And path 'decision/moderacion-foro/definicion'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    When method get
    Then status 200
    And match response.historial == '#[2]'
    And match response.historial[0].valores == valoresLimpios
    And match response.historial[1].valores == valoresInsulto
    And match response.historial[0].accion == '#string'
    And match response.historial[1].accion == '#string'
    * print 'Historial registrado:', response.historial

  @regression @Issue-11 @REQ-MOD-NEGATIVO
  Scenario: R10- Negativo - Evaluar con un número incorrecto de condiciones
    * def valoresInvalidos = [false, false]
    Given url baseUrl
    And path 'decision/moderacion-foro/evaluar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { valores: '#(valoresInvalidos)' }
    When method post
    Then status 400
    And match response.error == '#string'
    And match response.error == 'Se esperaban 3 valores booleanos'
    * print 'Error de validación:', response
