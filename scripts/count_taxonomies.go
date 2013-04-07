package main

//
// count_taxonomies.go
// a faster alternative to lederhosen count_taxonomies
// (c2013) Austin G. Davis-Richardson
// MIT v3 LICENSE
//
// COMPILATION:
//
// 1.) Install Go (http://golang.org)
// 2.) go build count_taxonomies.go
// 3.) At this point you're ready to go
//
// USAGE:
// count_taxonomies input.uc > output.tax
//

import (
  "encoding/csv"
  "fmt"
  "io"
  "os"
)

func main() {

  table := map[string]int64{}

  infile := os.Args[1]

  file, err := os.Open(infile)

  if err != nil {
    panic(err)
  }

  defer file.Close()

  reader := csv.NewReader(file)
  reader.Comma = '\t'

  // count items
  for {
    record, err := reader.Read()
    if err == io.EOF {
      break
    } else if err != nil {
      panic(err)
    }

    // key is the name of the target sequence.
    // column 8 in the uc file (9 if you start
    // counting at 0)
    key := record[9]

    if _, present := table[key]; present {
      table[key] = table[key] + 1
    } else {
      table[key] = 1
    }

  }

  for k, _ := range table {
    fmt.Printf("%v,%v\n", k, table[k])
  }
}
