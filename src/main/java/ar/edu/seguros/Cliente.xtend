package ar.edu.seguros

import java.time.LocalDate
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

abstract class Cliente {
	@Accessors(PUBLIC_GETTER) int deuda = 0
	
	def void generarDeuda(int monto) {
		deuda = deuda + monto
	}

	def tieneDeuda() {
		deuda > 0
	}

	def boolean puedeCobrarSiniestro()
}

class ClienteNormal extends Cliente {
	
	List<LocalDate> diasDeConsulta = newArrayList
	
	def void registrarConsulta() {
		val ultimaConsulta = this.diasDeConsulta.last
		if (this.tieneDeuda && ultimaConsulta < LocalDate.now) {
			this.diasDeConsulta.add(LocalDate.now())
		}
	}

	def tieneConsultas(LocalDate dia) {
		this.diasDeConsulta.exists [ diaConsulta | diaConsulta === dia ]
	}

	override puedeCobrarSiniestro() {
		registrarConsulta
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