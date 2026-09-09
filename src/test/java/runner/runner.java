package runner;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;


public class runner {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:features")
                .outputCucumberJson(true) // <--- AQU� SE CONFIGURA
                .parallel(1);             // Define el n�mero de hilos concurrentes

        // Aserci�n para asegurar que el build de Gradle/Maven falle si alguna prueba no pasa
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}
// cucumber toma el feautre que es la expresion de el caso de prueba en lenguaje natural y lo convierte
// en pasos ejecutables

// karate  -> cucumber -> feature, Karate evita hacer el step definition

//Serenity -> cucumber -> step definition