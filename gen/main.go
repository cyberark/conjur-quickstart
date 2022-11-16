package main

import (
	"html/template"
	"os"
)

var tpl = `
- !policy
  id: BenchmarkSecrets
  body:
{{ range $i, $a := . }}
    - !variable secret_{{ $i }}
{{end}}
`

func main() {

	tt := template.Must(template.New("queue").Parse(tpl))
	file, err := os.Create("new_secrets.yml")
	if err != nil {
		panic(err)
	}

	secretNames := make([]int, 150000)
	tt.Execute(file, secretNames)
	file.Close()
}
