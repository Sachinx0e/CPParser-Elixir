public class test_class {

     private long CPointer;
     private boolean mOwnsMemory = true;

     
     public test_class(int param1) {
          CPointer = test_class (param1);
     }
     private native static long test_class(int param1);
     

     public test_class(String param1) {
          CPointer = test_class (param1);
     }
     private native static long test_class(String param1);
     

     
     public void test_function(int param1){
         test_function (CPointer,param1);
     }
     private native static void test_function(long CPointer,int param1);

     public String test_function_return(){
         return test_function_return (CPointer);
     }
     private native static String test_function_return(long CPointer);

     public native static String test_function_static(int param1);


     protected void finalize(){
          if(mOwnsMemory){
             finalize(CPointer);
          }
     }
     private native static void finalize(long CPointer);

     public void setMemown(boolean ownsMemory){
          mOwnsMemory = ownsMemory;
     }

}
