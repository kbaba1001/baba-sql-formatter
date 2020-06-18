# -*- coding: utf-8 -*-

require "anbt-sql-formatter/helper"

=begin
AnbtSqlFormatter: SQL整形ツール. SQL文を決められたルールに従い整形します。

フォーマットを実施するためには、入力されるSQLがSQL文として妥当であることが前提条件となります。

このクラスが準拠するSQL整形のルールについては、下記URLを参照ください。
http://homepage2.nifty.com/igat/igapyon/diary/2005/ig050613.html

このクラスは SQLの変換規則を表します。

@author WATANABE Yoshinori (a-san) : original version at 2005.07.04.
@author IGA Tosiki : marge into blanc Framework at 2005.07.04
@author sonota : porting to Ruby 2009-2010
=end

class AnbtSql
  class Rule

    include StringUtil

    attr_accessor :keyword, :indent_string, :function_names, :space_after_comma
    attr_accessor :kw_multi_words

    # nl: New Line
    # x: the keyword
    attr_accessor :kw_plus1_indent_x_nl
    attr_accessor :kw_minus1_indent_nl_x_plus1_indent
    attr_accessor :kw_nl_x
    attr_accessor :kw_nl_x_plus1_indent

    # Limit number of values per line in IN clause to this value.
    #
    # nil:: one value per line (default)
    # n (>=2):: n values per line
    # ONELINE_IN_VALUES_NUM:: all values in one line
    attr_accessor :in_values_num

    # キーワードの変換規則: 何もしない
    KEYWORD_NONE = 0

    # キーワードの変換規則: 大文字にする
    KEYWORD_UPPER_CASE = 1

    # キーワードの変換規則: 小文字にする
    KEYWORD_LOWER_CASE = 2

    # IN の値を一行表示する場合の in_values_num 値
    ONELINE_IN_VALUES_NUM = 0

    def initialize
      # キーワードの変換規則.
      @keyword = KEYWORD_UPPER_CASE

      # インデントの文字列. 設定は自由入力とする。
      # 通常は " ", " ", "\t" のいずれか。
      @indent_string = "    "

      @space_after_comma = false

      # __foo
      # ____KW
      # @kw_plus1_indent_x_nl = %w(INSERT INTO CREATE DROP TRUNCATE TABLE CASE)
      @kw_plus1_indent_x_nl = %w(CASE)

      # ____foo
      # __KW
      # ____bar
      @kw_minus1_indent_nl_x_plus1_indent = %w(FROM WHERE SET HAVING WITH)
      @kw_minus1_indent_nl_x_plus1_indent.concat ["PARTITION BY", "ORDER BY", "GROUP BY"]

      # __foo
      # ____KW
      @kw_nl_x_plus1_indent = %w(USING THEN)
      # @kw_nl_x_plus1_indent = %w(USING THEN)

      # __foo
      # __KW
      @kw_nl_x = %w(
        ON
        OR
        WHEN
        ELSE
        LEFT\ JOIN
        LEFT\ OUTER\ JOIN
        RIGHT\ JOIN
        RIGHT\ OUTER\ JOIN
        INNER\ JOIN
        CROSS\ JOIN
      )

      @kw_multi_words = [
        "PARTITION BY",
        "ORDER BY",
        "GROUP BY",
        "LEFT JOIN",
        "LEFT OUTER JOIN",
        "RIGHT JOIN",
        "RIGHT OUTER JOIN",
        "INNER JOIN",
        "CROSS JOIN",
        "AT TIME ZONE"
      ]

      # 関数の名前。
      # Java版は初期値 null
      @function_names =
        [
         # getNumericFunctions
         "ABS", "ACOS", "ASIN", "ATAN", "ATAN2", "BIT_COUNT", "CEILING",
         "COS", "COT", "DEGREES", "EXP", "FLOOR", "LOG", "LOG10",
         "MAX", "MIN", "MOD", "PI", "POW", "POWER", "RADIANS", "RAND",
         "ROUND", "SIN", "SQRT", "TAN", "TRUNCATE",
         # getStringFunctions
         "ASCII", "BIN", "BIT_LENGTH", "CHAR", "CHARACTER_LENGTH",
         "CHAR_LENGTH", "CONCAT", "CONCAT_WS", "CONV", "ELT",
         "EXPORT_SET", "FIELD", "FIND_IN_SET", "HEX,INSERT", "INSTR",
         "LCASE", "LEFT", "LENGTH", "LOAD_FILE", "LOCATE", "LOCATE",
         "LOWER", "LPAD", "LTRIM", "MAKE_SET", "MATCH", "MID", "OCT",
         "OCTET_LENGTH", "ORD", "POSITION", "QUOTE", "REPEAT",
         "REPLACE", "REVERSE", "RIGHT", "RPAD", "RTRIM", "SOUNDEX",
         "SPACE", "STRCMP", "SUBSTRING", "SUBSTRING", "SUBSTRING",
         "SUBSTRING", "SUBSTRING_INDEX", "TRIM", "UCASE", "UPPER",
         # getSystemFunctions
         "DATABASE", "USER", "SYSTEM_USER", "SESSION_USER", "PASSWORD",
         "ENCRYPT", "LAST_INSERT_ID", "VERSION",
         # getTimeDateFunctions
         "DAYOFWEEK", "WEEKDAY", "DAYOFMONTH", "DAYOFYEAR", "MONTH",
         "DAYNAME", "MONTHNAME", "QUARTER", "WEEK", "YEAR", "HOUR",
         "MINUTE", "SECOND", "PERIOD_ADD", "PERIOD_DIFF", "TO_DAYS",
         "FROM_DAYS", "DATE_FORMAT", "TIME_FORMAT", "CURDATE",
         "CURRENT_DATE", "CURTIME", "CURRENT_TIME", "NOW", "SYSDATE",
         "CURRENT_TIMESTAMP", "UNIX_TIMESTAMP", "FROM_UNIXTIME",
         "SEC_TO_TIME", "TIME_TO_SEC",
        ]
      redshift_function_names = %w(
        CURRENT_SCHEMA CURRENT_SCHEMAS HAS_DATABASE_PRIVILEGE
        HAS_SCHEMA_PRIVILEGE HAS_TABLE_PRIVILEGE
        AGE CURRENT_TIME CURRENT_TIMESTAMP LOCALTIME ISFINITE NOW
        ASCII GET_BIT GET_BYTE SET_BIT SET_BYTE TO_ASCII
        LISTAGG MEDIAN PERCENTILE_CONT PERCENTILE_DISC APPROXIMATE PERCENTILE_DISC
        APPROXIMATE PERCENTILE_DISC AVG COUNT LISTAGG MAX MEDIAN MIN PERCENTILE_CONT
        STDDEV_SAMP STDDEV_POP SUM VAR_SAMP VAR_POP
        BIT_AND BIT_OR BOOL_AND BOOL_OR
        AVG COUNT CUME_DIST DENSE_RANK FIRST_VALUE LAST_VALUE LAG LEAD LISTAGG MAX
        MEDIAN MIN NTH_VALUE NTILE PERCENT_RANK PERCENTILE_CONT PERCENTILE_DISC RANK
        RATIO_TO_REPORT ROW_NUMBER STDDEV_SAMP STDDEV_POP SUM VAR_SAMP VAR_POP
        COALESCE DECODE GREATEST LEAST NVL NVL2 NULLIF
        ADD_MONTHS AT\ TIME\ ZONE CONVERT_TIMEZONE CURRENT_DATE DATE_CMP DATE_CMP_TIMESTAMP
        DATE_CMP_TIMESTAMPTZ DATE_PART_YEAR DATEADD DATEDIFF DATE_PART DATE_TRUNC EXTRACT
        GETDATE INTERVAL_CMP LAST_DAY MONTHS_BETWEEN NEXT_DAY SYSDATE TIMEOFDAY TIMESTAMP_CMP
        TIMESTAMP_CMP_DATE TIMESTAMP_CMP_TIMESTAMPTZ TIMESTAMPTZ_CMP TIMESTAMPTZ_CMP_DATE
        TIMESTAMPTZ_CMP_TIMESTAMP TIMEZONE TO_TIMESTAMP TRUNC
        GeometryType ST_AddPoint ST_Area ST_AsBinary ST_AsEWKB ST_AsEWKT ST_AsGeoJSON ST_AsText
        ST_Azimuth ST_Contains ST_CoveredBy ST_Covers ST_Dimension ST_Disjoint ST_Distance
        ST_DistanceSphere ST_DWithin ST_EndPoint ST_Envelope ST_Equals ST_GeometryN ST_GeometryType
        ST_GeomFromEWKB ST_GeomFromText ST_GeomFromWKB ST_Intersects ST_IsClosed ST_IsCollection
        ST_IsEmpty ST_Length ST_Length2D ST_LineFromMultiPoint ST_MakeLine ST_MakePoint ST_MakePolygon
        ST_MemSize ST_NPoints ST_NRings ST_NumGeometries ST_NumInteriorRings ST_NumPoints ST_Perimeter
        ST_Perimeter2D ST_Point ST_PointN ST_Polygon ST_RemovePoint ST_SetSRID ST_SRID ST_StartPoint
        ST_Touches ST_Within ST_X ST_XMax ST_XMin ST_Y ST_YMax ST_YMin
        ABS ACOS ASIN ATAN ATAN2 CBRT CEILING CEIL COS COT DEGREES DEXP DLOG1 DLOG10 EXP FLOOR LN LOG
        MOD PI POWER RADIANS RANDOM ROUND SIN SIGN SQRT TAN TO_HEX TRUNC
        BPCHARCMP BTRIM BTTEXT_PATTERN_CMP CHAR_LENGTH CHARACTER_LENGTH CHARINDEX CHR
        CONCAT CRC32 FUNC_SHA1 INITCAP LEFT RIGHT LEN LENGTH LOWER LPAD RPAD LTRIM MD5 OCTET_LENGTH
        POSITION QUOTE_IDENT QUOTE_LITERAL REGEXP_COUNT REGEXP_INSTR REGEXP_REPLACE REGEXP_SUBSTR
        REPEAT REPLACE REPLICATE REVERSE RTRIM SHA SHA1 SHA2 SPLIT_PART STRPOS STRTOL SUBSTRING
        TEXTLEN TRANSLATE TRIM UPPER CHECKSUM FNV_HASH
        IS_VALID_JSON IS_VALID_JSON_ARRAY JSON_ARRAY_LENGTH JSON_EXTRACT_ARRAY_ELEMENT_TEXT JSON_EXTRACT_PATH_TEXT
        CAST CONVERT TO_CHAR TO_DATE TO_NUMBER
        CHANGE_QUERY_PRIORITY CHANGE_SESSION_PRIORITY CHANGE_USER_PRIORITY CURRENT_SETTING
        PG_CANCEL_BACKEND PG_TERMINATE_BACKEND SET_CONFIG
        CURRENT_DATABASE CURRENT_SCHEMA CURRENT_SCHEMAS CURRENT_USER CURRENT_USER_ID HAS_DATABASE_PRIVILEGE
        HAS_SCHEMA_PRIVILEGE HAS_TABLE_PRIVILEGE PG_BACKEND_PID PG_GET_COLS PG_GET_LATE_BINDING_VIEW_COLS
        PG_LAST_COPY_COUNT PG_LAST_COPY_ID PG_LAST_UNLOAD_ID PG_LAST_QUERY_ID PG_LAST_UNLOAD_COUNT
        SESSION_USER SLICE_NUM USER VERSION
      )
      @function_names.concat(redshift_function_names).uniq!
    end


    def function?(name)
      if (@function_names == nil)
        return false
      end

      for i in 0...(@function_names.length)
        if (equals_ignore_case(@function_names[i], name))
          return true
        end
      end

      return false
    end
  end
end
