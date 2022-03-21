BEGIN
  ORDS_ADMIN.ENABLE_OBJECT(
    p_schema => 'quickstart',
    p_object=>'STORES'
  );
  COMMIT;
END;
