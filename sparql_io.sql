create procedure DB.DBA.SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE (inout ses any, inout metas any, inout rset any, in is_js integer := 0, in esc_mode integer := 1, in pure_html integer := 0)
{
  declare varctr, varcount, resctr, rescount integer;
  declare trnewline, newline varchar;
  varcount := length (metas[0]);
  rescount := length (rset);
  if (esc_mode = 13)
    {
      newline := '';
      trnewline := ''');\ndocument.writeln(''';
    }
  else
    newline := trnewline := '\n';
  if (is_js)
    {
      http ('document.writeln(''', ses);
      SPARQL_RESULTS_JAVASCRIPT_HTML_WRITE(ses,metas,rset,0,13);
      http (''');', ses);
      return;
   }
  http ('<html><head>', ses);
  http ('<link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css" rel="stylesheet" />\n',ses);
  http ('<link href="/css/gcis.css" rel="stylesheet" />\n');
  http ('<script src="//code.jquery.com/jquery-1.10.1.min.js"></script>\n', ses);
  http ('<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>\n', ses);
  http ('<script src="/js/sparql.js"></script>', ses);
  http ('</head><body>', ses);
  http ('<table class="sparql table table-condenseded table-bordered table-striped squeeze" id="sparql_results">', ses);
  http (trnewline || '  <tr>', ses);
  http ('\n    <th>Row</th>', ses);
  for (varctr := 0; varctr < varcount; varctr := varctr + 1)
    {
      http(newline || '    <th>', ses);
      http_escape (metas[0][varctr][0], esc_mode, ses, 0, 1);
      http('</th>', ses);
    }
  http (newline || '  </tr>', ses);
  for (resctr := 0; resctr < rescount; resctr := resctr + 1)
    {
      http(trnewline || '  <tr>', ses);
      http('\n    <td>', ses);
      http(cast((resctr + 1) as varchar), ses);
      http('</td>', ses);
      for (varctr := 0; varctr < varcount; varctr := varctr + 1)
        {
          declare val any;
          val := rset[resctr][varctr];
          if (val is null)
            {
              http(newline || '    <td></td>', ses);
              goto end_of_val_print; -- see below
            }
          http(newline || '    <td>', ses);
          if (isiri_id (val))
            http_escape (id_to_iri (val), esc_mode, ses, 1, 1);
          else if (isstring (val) and (1 = __box_flags (val)))
            http_escape (val, esc_mode, ses, 1, 1);
          else if (__tag of varchar = __tag (val))
            {
              http_escape (val, esc_mode, ses, 1, 1);
            }
	  else if (185 = __tag (val)) -- string output
	    {
              http_escape (cast (val as varchar), esc_mode, ses, 1, 1);
	    }
	  else if (__tag of XML = rdf_box_data_tag (val)) -- string output
	    {
              if (is_js)
                {
                  declare tmpses any;
                  tmpses := string_output();
                  http_value (val, 0, tmpses);
                  http_escape (cast (tmpses as varchar), esc_mode, ses, 1, 1);
                }
              else
                http_value (val, 0, ses);
	    }
	  else if (pure_html and __tag of rdf_box = __tag (val))
	      http_rdf_object (val, ses, 1);
          else
            {
              http_escape (__rdf_strsqlval (val), esc_mode, ses, 1, 1);
            }
          http ('</td>', ses);
end_of_val_print: ;
        }
      http(newline || '  </tr>', ses);
    }
  http (trnewline || '</table>', ses);
  http ('</body><html>', ses);
}
;

