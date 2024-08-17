package main

import (
	"crypto/tls"
	"fmt"
	"io"
	"log"
	"net"
)

func main() {
	tlsConfig := &tls.Config{
		GetCertificate: func(info *tls.ClientHelloInfo) (*tls.Certificate, error) {
			return nil, fmt.Errorf("no certificate found for server name: %s", info.ServerName)
		},
	}

	// Start the TLS listener
	listener, err := tls.Listen("tcp", ":4443", tlsConfig)
	if err != nil {
		log.Fatalf("Failed to create listener: %v", err)
	}
	fmt.Println("Listening on :4443")
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Failed to accept connection: %v", err)
			continue
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	tlsConn, ok := conn.(*tls.Conn)
	if !ok {
		log.Println("Not a TLS connection")
		return
	}

	// Perform the TLS handshake
	if err := tlsConn.Handshake(); err != nil {
		log.Printf("TLS handshake failed: %v", err)
		return
	}

	// Get the connection state
	state := tlsConn.ConnectionState()

	// Log information about the connection
	log.Printf("New connection from %s", tlsConn.RemoteAddr())
	log.Printf("Server Name: %s", state.ServerName)
	if len(state.PeerCertificates) > 0 {
		log.Printf("Client Certificate Common Name: %s", state.PeerCertificates[0].Subject.CommonName)
	}

	// Echo back to the client
	io.Copy(conn, conn)
}
