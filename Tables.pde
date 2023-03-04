
float [] _tableLinearTodB;
int TABLE_SIZE = 256;

void initTables() {
  
  initLinearTodB();
}

void initLinearTodB() {
  
  _tableLinearTodB = new float[TABLE_SIZE];
  _tableLinearTodB[0] = -144.0;
  for(int i=1; i<TABLE_SIZE; i++) {
    _tableLinearTodB[i] = (float)(20 * Math.log10(i/float(TABLE_SIZE)));
    
  }  
}

float cvLinearTodB(float v) {
  return _tableLinearTodB[int(v * TABLE_SIZE)];
}
