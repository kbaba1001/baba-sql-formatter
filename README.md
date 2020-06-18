# baba-sql-formatter

forked [anbt-sql-formatter](https://github.com/sonota88/anbt-sql-formatter).

Support redshift function.

## Environment

Setup ruby: https://www.ruby-lang.org/en/documentation/installation/

## Usage

```
$ echo "select a,b from c;" | ./bin/baba-sql-formatter
SELECT
        a
        , b
    FROM
        c
;
```

```
$ ./bin/baba-sql-formatter sample.sql
```

## License

GNU Lesser General Public License.

## Authors

kbaba1001

## anbt-sql-formatter's authors

* sonota:: Porting to Ruby

Following are Authors of BlancoSqlFormatter(original Java version).

* 渡辺義則 / Yoshinori WATANABE / A-san:: Early development
* 伊賀敏樹 (Tosiki Iga / いがぴょん):: Maintainance

## Customize

* In AnbtSql::Rule:
  * Function names
  * Rules for linefeed and indentation
  * Characters for indentation
  * Upcase or Downcase
* More farther:
  Override AnbtSql::Formatter#format_list_main_loop
  by inheritance or monkeypathcing.

## Test

 $ ./test.sh
