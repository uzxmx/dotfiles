package main

import (
	"database/sql"
	"database/sql/driver"
	"errors"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"io/ioutil"
	"net/url"
	"os"
	"strconv"
	"strings"
)

// BitBool is an implementation of a bool for the MySQL type BIT(1).
// This type allows you to avoid wasting an entire byte for MySQL's boolean type TINYINT.
type BitBool bool

func (b BitBool) Value() (driver.Value, error) {
	if b {
		return []byte{1}, nil
	} else {
		return []byte{0}, nil
	}
}

func (b *BitBool) Scan(src interface{}) error {
	v, ok := src.([]byte)
	if !ok {
		return errors.New("bad []byte type assertion")
	}
	*b = v[0] == 1
	return nil
}

func (b BitBool) String() string {
	if b {
		return "true"
	} else {
		return "false"
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: mysql csv

Export MySQL data as a CSV file.

Options:
  -q <query> a select statement to query rows
  -o <file> file to output

  -u <user> user
  -p <password> password
  -d <database> database
  --host <host> default is 127.0.0.1
  --port <port> default is 3306
  --timezone <timezone> default is Asia/Shanghai
`)
	os.Exit(1)
}

func main() {
	var query, outfile string
	var user, password, dbname string
	host := "127.0.0.1"
	port := uint64(3306)
	timezone := "Asia/Shanghai"
	var err error

	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-q":
			query = os.Args[i+1]
			i++
		case "-o":
			outfile = os.Args[i+1]
			i++
		case "-u":
			user = os.Args[i+1]
			i++
		case "-p":
			password = os.Args[i+1]
			i++
		case "-d":
			dbname = os.Args[i+1]
			i++
		case "--host":
			host = os.Args[i+1]
			i++
		case "--port":
			port, err = strconv.ParseUint(os.Args[i+1], 10, 32)
			if err != nil {
				panic(err)
			}
			i++
		case "--timezone":
			timezone = os.Args[i+1]
			i++
		default:
			usage()
		}
	}

	if len(query) == 0 {
		panic("A select statement should be specified by -q option.")
	}

	if len(outfile) == 0 {
		panic("An output file should be specified by -o option.")
	}

	connStr := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8&loc=%s&parseTime=true", user, password, host, port, dbname, url.PathEscape(timezone))

	db, err := sql.Open("mysql", connStr)
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	rows, err := db.Query(query)
	if err != nil {
		panic(err)
	}

	var content strings.Builder
	cols, _ := rows.Columns()
	types, _ := rows.ColumnTypes()
	for i, t := range types {
		if i != 0 {
			content.WriteRune(',')
		}
		content.WriteString(t.Name())
	}
	content.WriteString("\n")

	for rows.Next() {
		vals := make([]interface{}, len(cols))
		for i, _ := range cols {
			t := types[i].DatabaseTypeName()
			switch t {
			case "BIGINT":
				vals[i] = new(sql.NullInt64)
			case "BIT":
				vals[i] = new(BitBool)
			case "INT":
				vals[i] = new(int)
			case "VARCHAR", "TEXT", "TIME":
				vals[i] = new(sql.NullString)
			case "DATETIME", "DATE":
				vals[i] = new(sql.NullTime)
			case "DECIMAL":
				vals[i] = new(sql.NullFloat64)
			default:
				panic(fmt.Errorf("Unsupported column type: %s", t))
			}
		}

		err := rows.Scan(vals...)
		if err != nil {
			panic(err)
		}
		for i, _ := range cols {
			if i != 0 {
				content.WriteRune(',')
			}

			switch v := vals[i].(type) {
			case *sql.NullInt64:
				fmt.Fprintf(&content, "%d", v.Int64)
			case *int:
				fmt.Fprintf(&content, "%d", *v)
			case *sql.NullString:
				if v.Valid {
					// Quote the string if it contains a comma.
					if strings.Contains(v.String, ",") {
						fmt.Fprintf(&content, "\"%s\"", v.String)
					} else {
						content.WriteString(v.String)
					}
				}
			case *sql.NullFloat64:
				fmt.Fprintf(&content, "%f", v.Float64)
			case *sql.NullTime:
				if v.Valid {
					content.WriteString(v.Time.String())
				}
			case *BitBool:
				fmt.Fprintf(&content, "%s", v.String())
			default:
				panic(fmt.Errorf("Unknown column: %s", v))
			}

		}
		content.WriteString("\n")
	}

	ioutil.WriteFile(outfile, []byte(content.String()), 0644)
	fmt.Printf("Data has been exported to %s\n", outfile)
}
