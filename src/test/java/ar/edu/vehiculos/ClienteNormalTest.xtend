package ar.edu.vehiculos

import ar.edu.seguros.ClienteNormal
import java.time.LocalDate
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

import static org.junit.jupiter.api.Assertions.assertTrue

@DisplayName("Dado un cliente normal")
class ClienteNormalTest {

	ClienteNormal clienteNormal
	
	@BeforeEach
	def void init(){
		clienteNormal = new ClienteNormal
	}

	@DisplayName("si no tiene deuda puede cobrar el siniestro")
	@Test
	def void clienteSinDeudaPuedeCobrarSiniestro() {
		assertTrue(clienteNormal.puedeCobrarSiniestro, "El cliente normal sin deuda debería poder crear un siniestro")
	}

	@DisplayName("si tiene deuda no puede cobrar el siniestro y debe registrar la fecha de hoy como consultada")
	@Test
	def void clienteConDeudaNoPuedeCobrarSiniestro() {
		clienteNormal.generarDeuda(50)
		assertTrue(clienteNormal.puedeCobrarSiniestro, "El cliente normal sin deuda debería poder crear un siniestro")
		assertTrue(clienteNormal.tieneConsultas(LocalDate.now))
	}
}