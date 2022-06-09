BEGIN
  ORDS_ADMIN.ENABLE_OBJECT(
    p_schema => 'admin',
    p_object=>'STORES'
  );

  ORDS_ADMIN.ENABLE_OBJECT(
    p_schema => 'admin',
    p_object=>'PRODUCTS'
  );  
  COMMIT;
END;
