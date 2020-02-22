package ar.edu.vehiculos

import ar.edu.seguros.Auto
import ar.edu.seguros.Flota
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

import static org.junit.jupiter.api.Assertions.assertFalse
import static org.junit.jupiter.api.Assertions.assertTrue

@DisplayName("Dado un cliente de flota con muchos autos")
class FlotaMuchosAutosTest {
	
	Flota flotaConMuchosAutos
	
	@BeforeEach
	def void init() {
		flotaConMuchosAutos = new Flota => [
			agregarAuto(new Auto("ab028122", 2008))
			agregarAuto(new Auto("ts282828", 2006))
			agregarAuto(new Auto("jy844557", 2009))
			agregarAuto(new Auto("lo097521", 2011))
			agregarAuto(new Auto("oo345365", 2017))
			agregarAuto(new Auto("bj325321", 2009))	
		]
	}

	@Test
	@DisplayName("si no tiene deuda puede cobrar el siniestro")
	def void sinDeudaPuedeCobrarSiniestro() {
		assertTrue(flotaConMuchosAutos.puedeCobrarSiniestro)
	}

	@Test
	@DisplayName("si tiene una deuda grande no puede cobrar un siniestro")
	def void conDeudaGrandeNoPuedeCobrarSiniestro() {
		flotaConMuchosAutos.generarDeuda(15000)
		assertFalse(flotaConMuchosAutos.puedeCobrarSiniestro, "una flota que tiene una deuda abultada no puede cobrar un siniestro")
	}
	
}