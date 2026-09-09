function fn() {
    var config = {
        env: karate.env || 'dev'
    };

    // Simplifica y formatea el JSON/XML de los Requests y Responses en la consola
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);

    return config;
}