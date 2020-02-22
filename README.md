
# Ejercicio de Seguros - Metodología para la corrección de errores

![vehicle insurance](images/vehicles.png) 

## Dominio

Un sistema de seguros de automotor define cuándo pagar un siniestro, las condiciones pueden variar:

- para los clientes normales, si no son morosos (la deuda debe ser 0)
- para las flotas de autos, se soporta una deuda de hasta $ 10.000 si el cliente tiene más de 5 vehículos ó hasta $ 5.000 en caso contrario

> Como requerimiento extra, los clientes normales deben registran las fechas en los que se consulta si se puede pagar un siniestro **solamente cuando tienen deuda** (sin duplicarlas, si un cliente con deuda consultó 3 veces el sábado pasado y 5 veces el lunes, debe figurar el sábado y el lunes como días en los que se realizó la consulta).

## Objetivo

Queremos entender diferentes metodologías para corregir errores. 

## To TDD or not to TDD

Si resolvemos el ejercicio mediante la técnica del TDD (Test Driven Development), la primera ventaja que tenemos es que los tests no solo guían nuestra metodología de trabajo, sino que permiten detectar los errores lo más tempranamente posible. Más allá de que usemos TDD a rajatabla o utilicemos un esquema mixto donde alternemos código de negocio / tests, **los tests son nuestra mejor herramienta para detectar errores y garantizar que fueron resueltos**.

## Primeros tests, primeros errores

Escribimos nuestra primera clase de test, concentrándonos en el escenario de la flota con muchos autos. Ejecutamos los tests y...

![test failed - first part](images/test_failed.png)

Primera noción intuitiva: si fallan todos los tests, puede haber un error general (del setup de los tests o más concretamente en la implementación de los objetos de negocio).

### Stack Trace

El stack trace permite recorrer la jerarquía de envío de mensajes directamente donde ocurrió el problema, nos conviene bucear desde el origen del problema hacia atrás:

![navigating the stack trace](/images/stack_trace.gif)

Ok, sabemos que el problema ocurre cuando queremos agregar un auto a la colección de autos del cliente. Cosas que podrían mejorarse:

- el mensaje de error `NullPointerException` nos da una pista, pero no dice qué referencia está sin inicializar
- al hacer click sobre el primer elemento del stack trace, no se posiciona en la línea donde verdaderamente ocurre el error, que es `autos.add(auto)`

No obstante, por el mensaje de error y por el método donde se ubica, está claro que el problema se origina en el mensaje `add` a la referencia `autos`, que está sin inicializar. Entonces, tenemos nuestro primer problema resuelto:

```xtend
class Flota extends Cliente {
  List<Auto> autos = newArrayList
```

Ejecutamos los tests:

![first test solved](/images/first_test_solved.png)

Ya estamos mejor, uno de los test pasa satisfactoriamente.

### Debugging

El segundo test se rompe, volvemos con la técnica de revisar el stack trace:

![second test failed](/images/second_test_failed.png)

El test permite darnos información relevante:

- sabemos que la flota tiene muchos autos
- y que tiene una deuda abultada (de $ 15.000)
- entonces no debería poder cobrar el siniestro...
- pero la condición **no** se cumple (falla el assert), porque sí estaría pudiendo cobrar el siniestro

Entonces una segunda opción es debuggear el test, pondremos un **breakpoint** que nos permite pausar el envío de mensajes y analizar el contexto:

![debugger_use.gif](/images/debugger_use.gif)

Para agregar el breakpoint podemos utilizar el _shortcut_ Ctrl + Shift + B, o bien click sobre el margen izquierdo de la línea. A continuación describimos el proceso que se puede ver en el video:

- ¿por qué definimos el breakpoint en la línea que compara la deuda contra el máximo de deuda? Porque el assert que falla nos lleva al mensaje `puedeCobrarSiniestro()` (F3 o ctrl + click), que tiene justamente esa línea
- luego seleccionamos solamente el test que falla en la ventana JUnit, y con el botón derecho elegimos el comando Debug, que nos sugiere cambiar la perspectiva de Eclipse. Aceptamos, ya que aparecen nuevas ventanas que nos serán muy útiles
- el test se ejecuta hasta el punto en el que tiene que evaluar la expresión `this.deuda < this.montoDeuda`, entonces se detiene la ejecución, se muestra el stack trace hasta donde llegamos y tenemos nosotros el control
- podemos avanzar a la siguiente línea, si la hubiera, con F6, con F5 avanzar hacia adentro (esto provoca que cualquier envío de mensaje nos haga ingresar al método del objeto al que llamamos), o continuar la ejecución normalmente (Resume - F8)

![debugger steps](/images/debugger_steps.gif)

- pero no vamos a avanzar todavía, podemos ver el contexto pasando el mouse sobre las referencias, o bien en la solapa Variables. Allí vemos que la deuda es de $ 15.000 (está correctamente inicializada), entonces tenemos que ver cuál es el monto máximo de la deuda...
- para poder averiguarlo, una opción podría haber sido extraer una variable local en la llamada al método:

![debugger extract local variable](/images/debugger_extract_local_variable.gif)

eso nos permite visualizar fácilmente los valores, pero nos obliga a tener variables locales (algo que nosotros no te aconsejamos)

- entonces otra opción es ir a la solapa Expressions, y escribir la expresión que queremos evaluar: un detalle interesante es que `this.montoMaximoDeuda` es una expresión válida en Xtend, pero no dentro del contexto del debugger, donde debemos agregar los paréntesis: `this.montoMaximoDeuda()` para que funcione
- y allí finalmente vemos que 15000 < 20000 se cumple, pero resulta que el monto máximo de una flota con muchos autos debería ser $ 10.000

Corregimos nuestro error 

```xtend
  def montoMaximoDeuda() {
    if (autos.size > 5) 10000 else 5000
  }
```

y ahora sí tenemos los dos tests ok.

### Contras del debugging

Debuggear es una herramienta útil para encontrar y solucionar un error:

- tenemos a mano todo el contexto de ejecución
- podemos inspeccionar las referencias (para pensar: ¿qué pasa con el encapsulamiento?)
- avanzar paso a paso y ver el cambio de estado de los objetos nos ayuda a entender lo que pasa

<br>
pero por otra parte es importante destacar

- que si bien es cómodo, necesitamos invertir tiempo en tener en nuestra mente el estado de los objetos,
- luego de un tiempo, nuestra atención pierde el foco y es fácil olvidar lo que estamos resolviendo
- es preferible estar concentrado a la hora de desarrollar y no confiar en que luego al debuggear lo podremos resolver.

## Búsqueda binaria del error

El [algoritmo de búsqueda binaria](https://en.wikipedia.org/wiki/Binary_search_algorithm) se suele aprender como técnica para adivinar un número, por ejemplo del 1 al 8:

- ¿es mayor a 4? sí (descartamos 1, 2, 3, 4, podrían ser 5, 6, 7, 8)
- ¿es mayor a 6? sí (descartamos 5, 6, podrían ser 7 u 8)
- ¿es mayor a 7? no => entonces es 7 (descartado 8, solo queda 7)

De esa misma manera trabajan los electricistas para encontrar una fuga eléctrica o un cortocircuito: se van detectando puntos intermedios por donde pasa el código hasta encontrar la falla.

En nuestro caso, se puede implementar de varias maneras, pero las más conocidas son dos:

- imprimir por consola para ir dejando rastros (como las miguitas de pan del cuento de Hansel y Gretel)
- o bien comentar el código para ver qué efectos tiene en el código


ClienteMoroso

## Comentar código

Una instrucción maliciosa


