
float [] _tableLinearTodB;
float [] _tableExp8;
float [] _tableExp8MapTo255;
int TABLE_SIZE = 256;

void initTables() {
  
  initLinearTodB();
}

void initLinearTodB() {
  
  _tableLinearTodB = new float[TABLE_SIZE];
  _tableExp8 = new float[TABLE_SIZE];
  _tableExp8MapTo255 = new float[TABLE_SIZE];

  _tableLinearTodB[0] = -144.0;
  for(int i=1; i<TABLE_SIZE; i++) {
    float vi = i/float(TABLE_SIZE);
    _tableLinearTodB[i] = (float)(20 * Math.log10(vi));
    _tableExp8[i] = mapCurve(vi,8);
  }  
}

float cvLinearTodB(float v) {
  v = constrain(v,0,1);
  return _tableLinearTodB[int(v * (TABLE_SIZE-1))];
}

float cvLinearToExp8(float v) {
  v = constrain(v,0,1);
  return _tableExp8[int(v*(TABLE_SIZE-1))];
}

float cvLinearToExp8255(float v) {
   v = constrain(v,0,1);
  return _tableExp8MapTo255[int(v*(TABLE_SIZE-1))];
}
