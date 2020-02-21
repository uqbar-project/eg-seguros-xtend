package ar.edu.seguros

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

abstract class Cliente {
	@Accessors(PUBLIC_GETTER) int deuda = 0
	
	def void generarDeuda(int monto) {
		deuda = deuda + monto
	}

	def boolean puedeCobrarSiniestro()
}

class ClienteNormal extends Cliente {
	override puedeCobrarSiniestro() {
		return deuda == 0
	}
}

class Flota extends Cliente {
	List<Auto> autos
	
	override puedeCobrarSiniestro() {
		this.deuda < this.montoMaximoDeuda
	}
	
	def montoMaximoDeuda() {
		if (autos.size > 5) 20000 else 5000
	}
	
	def agregarAuto(Auto auto) {
		autos.add(auto)
	}

}

@Data
class Auto {
	String patente
	int anio
}