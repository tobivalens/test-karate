@api @moduloLavanderia
Feature: Control de estados de la lavadora industrial automatizada
  Como ingeniero de pruebas del firmware de la lavadora
  Quiero validar las transiciones de estado según los eventos recibidos
  Para asegurar que el ciclo de lavado y la parada de emergencia funcionan correctamente

  @smoketest @Issue-13 @REQ-LAV-A
  Scenario: Cerrar tapa inicia el llenado de agua
    * def inicial = call read('@reiniciar')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Cerrar Tapa' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S2 (Llenando Agua)'
    And match response.accion == '#string'
    And match response.accion == 'Bloquear pestillo'
    * print 'Resultado de transición:', response

  @regression @Issue-14 @REQ-LAV-B
  Scenario: Nivel de agua correcto inicia el lavado
    * def inicial = call read('@irAS2')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Nivel OK' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S3 (Lavando)'
    And match response.accion == '#string'
    And match response.accion == 'Activar motor'
    * print 'Resultado de transición:', response

  @regression @Issue-15 @REQ-LAV-C1
  Scenario: Fin Lavado desde Lavando pasa a Centrifugando
    * def inicial = call read('@irAS3')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Fin Lavado' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S4 (Centrifugando)'
    * print 'Resultado de transición:', response

  @regression @Issue-16 @REQ-LAV-C2
  Scenario: Fin Lavado desde Centrifugando regresa a Tapa Abierta
    * def inicial = call read('@irAS4')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Fin Lavado' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S1 (Tapa Abierta)'
    * print 'Resultado de transición:', response

  @regression @Issue-17 @REQ-LAV-D1
  Scenario: Apertura forzosa durante el llenado activa la parada de emergencia
    * def inicial = call read('@irAS2')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Apertura Forzosa' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S5 (Parada de Emergencia)'
    And match response.accion == '#string'
    And match response.accion == 'Abrir válvula de descarga'
    * print 'Resultado de transición:', response

  @regression @Issue-18 @REQ-LAV-D2
  Scenario: Apertura forzosa durante el lavado activa la parada de emergencia
    * def inicial = call read('@irAS3')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Apertura Forzosa' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S5 (Parada de Emergencia)'
    And match response.accion == '#string'
    And match response.accion == 'Abrir válvula de descarga'
    * print 'Resultado de transición:', response

  @regression @Issue-19 @REQ-LAV-D3
  Scenario: Apertura forzosa durante el centrifugado activa la parada de emergencia
    * def inicial = call read('@irAS4')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Apertura Forzosa' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S5 (Parada de Emergencia)'
    And match response.accion == '#string'
    And match response.accion == 'Abrir válvula de descarga'
    * print 'Resultado de transición:', response

  @regression @Issue-20 @REQ-LAV-E
  Scenario: Reset del operador recupera el sistema desde emergencia
    * def inicial = call read('@irAS5')
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Reset Operador' }
    When method post
    Then status 200
    And match response.estadoNuevo == '#string'
    And match response.estadoNuevo == 'S1 (Tapa Abierta)'
    * print 'Resultado de transición:', response

  @regression @Issue-21 @REQ-LAV-INVALIDAS
  Scenario Outline: Bloquear eventos inválidos en los estados de reposo y emergencia
    * def estadoActual = '<estado_actual>'
    # Preparar cada estado desde S1 evita depender del orden previo de los casos.
    * def setupTag = estadoActual.startsWith('S1:') ? '@reiniciar' : estadoActual.startsWith('S2:') ? '@irAS2' : estadoActual.startsWith('S3:') ? '@irAS3' : estadoActual.startsWith('S4:') ? '@irAS4' : '@irAS5'
    * def setup = call read(setupTag)
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: '<evento>' }
    When method post
    Then status 200
    And match response.valida == false
    And match response.noDefinida == true
    * print 'Resultado del evento inválido:', response
    Given url baseUrl
    And path 'lavanderia/estado'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    When method get
    Then status 200
    And match response.estadoActual == '#string'
    And match response.estadoActual == estadoInicial.response.estadoActual
    * print 'Estado después del evento inválido:', response.estadoActual

    Examples:
      | estado_actual            | evento           |
      | S1: Tapa Abierta          | Nivel OK         |
      | S1: Tapa Abierta          | Fin Lavado       |
      | S1: Tapa Abierta          | Apertura Forzosa |
      | S1: Tapa Abierta          | Reset Operador   |
      | S5: Parada de Emergencia  | Cerrar Tapa      |
      | S5: Parada de Emergencia  | Nivel OK         |
      | S5: Parada de Emergencia  | Fin Lavado       |
      | S5: Parada de Emergencia  | Apertura Forzosa |

  @regression @Issue-22 @REQ-LAV-INVALIDAS
  Scenario Outline: Bloquear eventos inválidos en los estados activos del ciclo
    * def estadoActual = '<estado_actual>'
    # Preparar cada estado desde S1 evita depender del orden previo de los casos.
    * def setupTag = estadoActual.startsWith('S1:') ? '@reiniciar' : estadoActual.startsWith('S2:') ? '@irAS2' : estadoActual.startsWith('S3:') ? '@irAS3' : estadoActual.startsWith('S4:') ? '@irAS4' : '@irAS5'
    * def setup = call read(setupTag)
    * def estadoInicial = call read('@consultarEstado')
    * print 'Estado inicial:', estadoInicial.response.estadoActual
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: '<evento>' }
    When method post
    Then status 200
    And match response.valida == false
    And match response.noDefinida == true
    * print 'Resultado del evento inválido:', response
    Given url baseUrl
    And path 'lavanderia/estado'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    When method get
    Then status 200
    And match response.estadoActual == '#string'
    And match response.estadoActual == estadoInicial.response.estadoActual
    * print 'Estado después del evento inválido:', response.estadoActual

    Examples:
      | estado_actual      | evento         |
      | S2: Llenando Agua  | Cerrar Tapa    |
      | S2: Llenando Agua  | Fin Lavado     |
      | S2: Llenando Agua  | Reset Operador |
      | S3: Lavando        | Cerrar Tapa    |
      | S3: Lavando        | Nivel OK       |
      | S3: Lavando        | Reset Operador |
      | S4: Centrifugando  | Cerrar Tapa    |
      | S4: Centrifugando  | Nivel OK       |
      | S4: Centrifugando  | Reset Operador |

  @ignore @reiniciar
  Scenario: Helper reiniciar lavandería
    Given url baseUrl
    And path 'lavanderia/reiniciar'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And header Content-Length = '0'
    When method post
    Then status 200
    And match response.estadoActual == 'S1 (Tapa Abierta)'

  @ignore @consultarEstado
  Scenario: Helper consultar estado
    Given url baseUrl
    And path 'lavanderia/estado'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    When method get
    Then status 200
    And match response.estadoActual == '#string'

  @ignore @irAS2
  Scenario: Helper llegar a S2
    * def reinicio = call read('@reiniciar')
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Cerrar Tapa' }
    When method post
    Then status 200
    And match response.estadoNuevo == 'S2 (Llenando Agua)'

  @ignore @irAS3
  Scenario: Helper llegar a S3
    * def llenando = call read('@irAS2')
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Nivel OK' }
    When method post
    Then status 200
    And match response.estadoNuevo == 'S3 (Lavando)'

  @ignore @irAS4
  Scenario: Helper llegar a S4
    * def lavando = call read('@irAS3')
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Fin Lavado' }
    When method post
    Then status 200
    And match response.estadoNuevo == 'S4 (Centrifugando)'

  @ignore @irAS5
  Scenario: Helper llegar a S5
    * def llenando = call read('@irAS2')
    Given url baseUrl
    And path 'lavanderia/evento'
    And headers { Content-Type: 'application/json', Accept: 'application/json' }
    And request { evento: 'Apertura Forzosa' }
    When method post
    Then status 200
    And match response.estadoNuevo == 'S5 (Parada de Emergencia)'
