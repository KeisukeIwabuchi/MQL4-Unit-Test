//+------------------------------------------------------------------+
//|                                                     UnitTest.mqh |
//|                                 Copyright 2017, Keisuke Iwabuchi |
//|                                        https://order-button.com/ |
//+------------------------------------------------------------------+
#property strict


#ifndef _LOAD_MODULE_UNIT_TEST
#define _LOAD_MODULE_UNIT_TEST


/** defines */
#define IS_DEBUG 


/** Include header files. */
#include <mql4_modules\Env\Env.mqh>


/**
 * Unit testing for MQL4.
 * Compare results with expected values.
 */
class UnitTest
{
   private:
      /** @var string test_name  Name of unit test. */
      string test_name;
      
      /** @var int passed  Number of successed times. */
      int passed;
      
      /** @var int failed  Number of failed times. */
      int failed;
      
      /** @var string file_path  Folder containing test environment file. */
      string file_path;
       
      /** @var string files[]  List of environment files. */
      string files[];
       
      /** @var int index  Number of loaded environment files. */
      int index;
      
      /** @var int max  Maximum of the number of tests per one file. */
      int max;
      
      /** @var string last_load_file  Name of last loaded environment file. */
      string last_load_file;
   
   public:
      UnitTest(const string name = "", const string path = "");
      ~UnitTest(void);
      
      template<typename T>
      void TestValue(T result, T expected);
      void TestValue(int digits, double result, double expected);
      void TestValue(int digits, float result, float expected);
      
      template<typename T>
      void TestArray(T &result[], T &expected[]);
      void TestArray(int digits, double &result[], double &expected[]);
      void TestArray(int digits, float &result[], float &expected[]);
      
      bool loadNextEnvFile(void);
      
   private:
      void printSuccessMessage(void);
      template<typename T>
      void printErrorMessage(T result, T expected);
      void printArraySizeErrorMessage(int result_size, int expected_size);
};


/**
 * Start unit test.
 * If path exists, load the environment file.
 *
 * @param const string name  Name of unit test.
 * @param const string path  Folder containing test environment file.
 */
UnitTest::UnitTest(const string name = "", const string path = "")
{
   this.test_name = name;
   this.passed         = 0;
   this.failed         = 0;
   this.file_path      = path;
   this.index          = 0;
   this.max            = 0;
   this.last_load_file = "";
   
   /** Processing if path exists. */
   if(StringLen(this.file_path) > 0) {
      long   handle    = 0;
      string file_name = "";
      int    count     = 0;
   
      handle = FileFindFirst(this.file_path + "\\*", file_name);
      
      if(handle != INVALID_HANDLE) {
         /** Load the first file. */
         Env::loadEnvFile(this.file_path + "\\" + file_name);
         this.last_load_file = file_name;
      
         /** Insert file name in this.files[] */
         do {
            ResetLastError();
            FileIsExist(file_name);
            
            /** Skip for folders. */
            if(GetLastError() == ERR_FILE_IS_DIRECTORY) continue;
            
            ArrayResize(this.files, count + 1);
            this.files[count] = file_name;
            count++;
         }
         while(FileFindNext(handle, file_name));
      }
   }
   
   Print("*------------------ Unit Test Start ------------------*");
}


/**
 * Terminate the unit test.
 * Output the result.
 */
UnitTest::~UnitTest(void)
{
   if(this.failed == 0) {
      Print("UnitTest : ", this.test_name, " PASSED! ",
            this.passed, " tests are successful.");
   }
   else {
      Print("UnitTest : ", this.test_name, " FAILED. ",
            this.passed, "/", (this.passed + this.failed), 
            " tests are successful.");
   }
   
   Print("*------------------- Unit Test End -------------------*");
   PlaySound("news.wav");
}


/**
 * Compare result with expected.
 *
 * @param typename result  Result of target processing.
 * @param typename expected  Expected value.
 *
 * @return bool  Returns true if match, otherwise false.
 */
template<typename T>
void UnitTest::TestValue(T result, T expected)
{
   if(result != expected) {
      UnitTest::printErrorMessage(result, expected);
      return;
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * Compare result with expected.
 *
 * @param int digits  Number of decimal places.
 * @param double result  Result of target processing.
 * @param double expected  Expected value.
 *
 * @return bool  Returns true if match, otherwise false.
 */
void UnitTest::TestValue(int digits, double result, double expected)
{
   if(NormalizeDouble(result, digits) != NormalizeDouble(expected, digits)) {
      UnitTest::printErrorMessage(result, expected);
      return;
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * Compare result with expected.
 *
 * @param int digits  Number of decimal places.
 * @param float result  Result of target processing.
 * @param float expected  Expected value.
 *
 * @return bool  Returns true if match, otherwise false.
 */
void UnitTest::TestValue(int digits, float result, float expected)
{
   if(NormalizeDouble(result, digits) != NormalizeDouble(expected, digits)) {
      UnitTest::printErrorMessage(result, expected);
      return;
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * Compare result with expected.
 *
 * @param typename &result[]  Result of target processing.
 * @param typename &expected[]  Expected value.
 *
 * @return bool  Returns true if match, otherwise false.
 */
template<typename T>
void UnitTest::TestArray(T &result[], T &expected[])
{
   if(ArraySize(result) != ArraySize(expected)) {
      UnitTest::printArraySizeErrorMessage(ArraySize(result), 
                                           ArraySize(expected));
      return;
   }
   
   for(int i = 0; i < ArraySize(result); i++) {
      if(result[i] != expected[i]) {
         UnitTest::printErrorMessage(result[i], expected[i]);
         return;
      }
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * Compare result with expected.
 *
 * @param int digits  Number of decimal places.
 * @param double &result[]  Result of target processing.
 * @param double &expected[]  Expected value.
 *
 * @return bool  Returns true if match, otherwise false.
 */
void UnitTest::TestArray(int digits, double &result[], double &expected[])
{
   double value1, value2;

   if(ArraySize(result) != ArraySize(expected)) {
      UnitTest::printArraySizeErrorMessage(ArraySize(result), 
                                           ArraySize(expected));
      return;
   }
   
   for(int i = 0; i < ArraySize(result); i++) {
      value1 = NormalizeDouble(result[i], digits);
      value2 = NormalizeDouble(expected[i], digits);
      
      if(value1 != value2) {
         UnitTest::printErrorMessage(value1, value2);
         return;
      }
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * Compare result with expected.
 *
 * @param int digits  Number of decimal places.
 * @param float &result[]  Result of target processing.
 * @param float &expected[]  Expected value.
 *
 * @return bool  Returns true if match, otherwise false.
 */
void UnitTest::TestArray(int digits, float &result[], float &expected[])
{
   float value1, value2;

   if(ArraySize(result) != ArraySize(expected)) {
      UnitTest::printArraySizeErrorMessage(ArraySize(result), 
                                           ArraySize(expected));
      return;
   }
   
   for(int i = 0; i < ArraySize(result); i++) {
      value1 = (float)NormalizeDouble(result[i], digits);
      value2 = (float)NormalizeDouble(expected[i], digits);
      
      if(value1 != value2) {
         UnitTest::printErrorMessage(value1, value2);
         return;
      }
   }
   
   UnitTest::printSuccessMessage();
}


/**
 * Load the next environment file.
 *
 * @return bool  Returns true if successful, otherwise false.
 */
bool UnitTest::loadNextEnvFile(void)
{
   this.index++;
   if(this.index >= ArraySize(this.files)) return(false);

   Env::loadEnvFile(this.file_path + "\\" + this.files[this.index]);
   this.last_load_file = this.files[this.index];
   
   if(this.max == 0) this.max = this.passed + this.failed;
   
   return(true);
}


/**
 * Increase the number of successed cases.
 * Output the message.
 */
void UnitTest::printSuccessMessage(void)
{
   this.passed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Passed!");
   }
   else {
      Print("Test #", (this.passed + this.failed), " Passed!");
   }
}


/** 
 * Icrease the number of failed cases.
 * Output the message.
 *
 * @param typename result  Result value.
 * @param typename expected  Expected value.
 */
template<typename T>
void UnitTest::printErrorMessage(T result,T expected)
{
   this.failed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Failed. ",
            result, " instead of ", expected, ". ", 
            "Env File = ", this.last_load_file);
   }
   else {
      Print("Test #", (this.passed + this.failed), " Failed. ",
            result, " instead of ", expected, ". ", 
            "Env File = ", this.last_load_file);
   }
}


/** 
 * Icrease the number of failed cases.
 * Output the message.
 *
 * @param int result _size  Number of elements of result array.
 * @param int expected_size  Number of elements of expected array.
 */
void UnitTest::printArraySizeErrorMessage(int result_size, int expected_size)
{
   this.failed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Error. ",
            "Array size ", result_size, " instead of ", expected_size, ". ",
            "Env File = ", this.last_load_file);
   }
   else {
      Print("Test #", (this.passed + this.failed), " Error. ",
            "Array size ", result_size, " instead of ", expected_size, ". ",
            "Env File = ", this.last_load_file);
   }
}


#endif
