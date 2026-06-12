package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestWebsiteHandler(t *testing.T) {
	tests := []struct {
		path        string
		contentType string
		contains    string
	}{
		{path: "/", contentType: "text/html", contains: `href="https://github.com/golazy/golazy">Source</a>`},
		{path: "/styles.css", contentType: "text/css", contains: "--blue: #00add8"},
		{path: "/script.js", contentType: "text/javascript", contains: "navigator.clipboard"},
		{path: "/assets/golazy-horizontal.svg", contentType: "image/svg+xml", contains: "<svg"},
	}

	for _, test := range tests {
		t.Run(test.path, func(t *testing.T) {
			response := httptest.NewRecorder()
			request := httptest.NewRequest(http.MethodGet, test.path, nil)
			handler().ServeHTTP(response, request)

			if response.Code != http.StatusOK {
				t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
			}
			if !strings.Contains(response.Header().Get("Content-Type"), test.contentType) {
				t.Fatalf(
					"Content-Type = %q, want %q",
					response.Header().Get("Content-Type"),
					test.contentType,
				)
			}
			if !strings.Contains(response.Body.String(), test.contains) {
				t.Fatalf("response does not contain %q", test.contains)
			}
		})
	}
}
