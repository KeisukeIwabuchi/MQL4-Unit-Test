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
#include <mql4_modules\Order\Order.mqh>


/**
 * 単体テスト用クラス
 * 実行結果と予想値の比較をおこなう。
 */
class UnitTest
{
   private:
      /** @var string test_name 単体テスト名 */
      string test_name;
      
      /** @var int passed テスト成功回数 */
      int passed;
      
      /** @var int failed テスト失敗回数 */
      int failed;
      
      /** @var string file_path テスト用環境フォルダのパス */
      string file_path;
       
      /** @var string files[] テスト用環境フォルダ内のファイル名一覧 */
      string files[];
       
      /** @var int index 現在読み込んだファイルの数 */
      int index;
      
      /** @var int max 1ファイルあたりのテストの回数 */
      int max;
      
      /** @var string last_load_file 最後に読み込んだ環境ファイルの名前 */
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
      
      bool CreateDummyOrder(const int type, 
                            const int magic, 
                            const int count=1
                            );
      void TestOrderSend(const int magic, bool is_close=false);
      void TestOrderClose(const int magic);
      void TestOrderModify(const int      magic, 
                           const double   price      = -1,
                           const double   sl         = -1,
                           const double   tp         = -1,
                           const datetime expiration = -1
                           );
      void TestOrderDelete(const int magic);
      
      bool loadNextEnvFile(void);
      
   private:
      void printSuccessMessage(void);
      template<typename T>
      void printErrorMessage(T result, T expected);
      void printErrorMessage(void);
      void printArraySizeErrorMessage(int result_size, int expected_size);
      
      double CreateDummyLots(void);
      double CreateDummyPrice(const int type);
      double CreateDummySL(const int type, const double price);
      double CreateDummyTP(const int type, const double price);
};


/**
 * 単体テストを開始する
 * pathが指定されている場合は環境ファイルを読み込む
 *
 * @param const string name テスト名
 * @param const string path 環境ファイルへのが保存されているフォルダ
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
   
   /** pathが指定された場合の処理 */
   if(StringLen(this.file_path) > 0) {
      long   handle    = 0;
      string file_name = "";
      int    count     = 0;
   
      handle = FileFindFirst(this.file_path + "\\*", file_name);
      
      if(handle != INVALID_HANDLE) {
         /** 1件目の環境ファイルを読み込む */
         Env::loadEnvFile(this.file_path + "\\" + file_name);
         this.last_load_file = file_name;
      
         /** 環境ファイルの一覧をthis.files[]に入れる */
         do {
            ResetLastError();
            FileIsExist(file_name);
            
            /** ファイルではなくフォルダであればスキップ */
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
 * 単体テストを終了し、結果を出力する
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
 * resultとexpectedの値を比較する
 * 構造体をチェックしたいときは個別にTestValueに渡して使用
 *
 * @param typename result テスト対象となる処理の実行結果
 * @param typename expected 結果の予想値
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
 * resultとexpectedの値を比較する
 * 構造体をチェックしたいときは個別にTestValueに渡して使用
 *
 * @param int digits 小数点以下の桁数
 * @param double result テスト対象となる処理の実行結果
 * @param double expected 結果の予想値
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
 * resultとexpectedの値を比較する
 * 構造体をチェックしたいときは個別にTestValueに渡して使用
 *
 * @param int digits 小数点以下の桁数
 * @param float result テスト対象となる処理の実行結果
 * @param float expected 結果の予想値
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
 * resultとexpectedの値を比較する
 *
 * @param typename &result[] テスト対象となる処理の実行結果
 * @param typename &expected[] 結果の予想値
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
 * resultとexpectedの値を比較する
 *
 * @param int digits 小数点以下の桁数
 * @param double &result[] テスト対象となる処理の実行結果
 * @param double &expected[] 結果の予想値
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
 * resultとexpectedの値を比較する
 *
 * @param int digits 小数点以下の桁数
 * @param float &result[] テスト対象となる処理の実行結果
 * @param float &expected[] 結果の予想値
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
 * テスト用にポジションを生成する.
 *
 * @param const int type  生成するポジションの取引種別
 * @param const int magic ポジションのマジックナンバー
 * @param const int count 作成するポジションの数
 */
bool UnitTest::CreateDummyOrder(const int type, 
                                const int magic, 
                                const int count=1)
{
   double lots, price, sl, tp;
   
   for(int i = 0; i < count; i++) {
      RefreshRates();
      
      lots  = this.CreateDummyLots();
      price = this.CreateDummyPrice(type);
      sl    = this.CreateDummySL(type, price);
      tp    = this.CreateDummyTP(type, price);
   
      if(OrderSend(_Symbol, type, lots, price, 0, sl, tp, "", magic) == -1) {
         return(false);
      }
      Sleep(1000);
   }
   
   return(true);
}


/**
 * OrderSend処理の結果を判断する.
 * ポジションが0で無ければ成功, 0なら失敗と判断とする.
 * is_closeがtrueの場合, 
 * テスト完了後にチェック対象ポジションの決済を試みる.
 *
 * @param const int magic チェック対象のマジックナンバー
 * @param bool is_close テスト終了後にポジションを決済するか
 */
void UnitTest::TestOrderSend(const int magic, bool is_close=false)
{
   OpenPositions pos;
   if(!Order::getOrderCount(pos, magic)) {
      UnitTest::printErrorMessage();
   }
   
   if(pos.total_pos > 0) {
      UnitTest::printSuccessMessage();
   }
   else {
      UnitTest::printErrorMessage();
   }
}


/**
 * OrderClose処理の結果を判断する.
 * ポジション数が0であれば成功と判断する.
 * 保有中ポジションがあれば失敗と判断する.
 *
 * @param const int magic チェック対象のマジックナンバー
 */
void UnitTest::TestOrderClose(const int magic)
{
   OpenPositions pos;
   if(!Order::getOrderCount(pos, magic)) {
      UnitTest::printErrorMessage();
   }
   
   if(pos.open_pos == 0) {
      UnitTest::printSuccessMessage();
   }
   else {
      UnitTest::printErrorMessage();
   }
}


/**
 * OrderModify処理の結果を判断する.
 * 保有中ポジションの情報を取得し,
 * パラメーターと一致していれば成功と判断する.
 * 不一致がある場合やポジション情報を取得できなかった場合は
 * 失敗と判断する.
 * 
 * @param int magic         チェックするポジションのマジックナンバー
 * @param double price      発注価格, 確認しない場合は-1
 * @param double sl         TP, 確認しない場合は-1
 * @param double tp         SL, 確認しない場合は-1
 * @param double expiration 有効期限, 確認しない場合は-1
 */
void UnitTest::TestOrderModify(const int      magic, 
                               const double   price      = -1,
                               const double   sl         = -1,
                               const double   tp         = -1,
                               const datetime expiration = -1
                               )
{
   OrderData data[1];
   if(!Order::getOrderByTrades(magic, data)) {
      UnitTest::printErrorMessage();
   }
   
}


/**
 * OrderDelete処理の結果を判断する.
 * 待機注文の件数を確認し, 0であれば成功と判断する.
 * 待機注文が残っている場合は失敗と判断し,
 * 待機注文の決済を試みる.
 */
void UnitTest::TestOrderDelete(const int magic)
{
   OpenPositions pos;
   if(!Order::getOrderCount(pos, magic)) {
      UnitTest::printErrorMessage();
   }
   
   if(pos.pend_pos == 0) {
      UnitTest::printSuccessMessage();
   }
   else {
      UnitTest::printErrorMessage();
   }
}


/**
 * 次の環境ファイルを読み込む
 *
 * @return bool true:成功, false:失敗（全件読み込み完了済み）
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


/** 成功数を1増やし、メッセージを出力する。 */
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
 * 失敗数を1増やし、メッセージを出力する。
 *
 * @param typename result 結果値
 * @param typename expected 予想値
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
 * 失敗数を1増やし、メッセージを出力する。
 */
void UnitTest::printErrorMessage(void)
{
   this.failed++;
   
   if(StringLen(this.last_load_file) > 0) {
      int num = (this.passed + this.failed);
      while(num > this.max && this.max > 0) {
         num -= this.max;
      }
      Print("Test #", (this.index + 1), "-", num, " Failed. ",
            "Env File = ", this.last_load_file);
   }
   else {
      Print("Test #", (this.passed + this.failed), " Failed. ",
            "Env File = ", this.last_load_file);
   }
}


/** 
 * 失敗数を1増やし、メッセージを出力する。
 *
 * @param int result _size 結果配列の要素数
 * @param int expected_size 予想値配列の要素数
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


/**
 * 発注可能な取引数量値をランダムに生成する.
 *
 * @param double 生成されたランダムな取引数量
 */
double UnitTest::CreateDummyLots(void)
{
   int    digits  = 0;
   double step    = MarketInfo(_Symbol, MODE_LOTSTEP);
   double min_lot = MarketInfo(_Symbol, MODE_MINLOT);
   double max_lot = MarketInfo(_Symbol, MODE_MAXLOT);
   double lots    = 0;
   
   while(step < 1) {
      step *= 10;
      digits++;
   }
   
   lots = ((double)MathRand() / 32767.0) * (max_lot - min_lot) + min_lot;
   lots = NormalizeDouble(lots, digits);
   if(lots > max_lot) lots = max_lot;
   if(lots < min_lot) lots = min_lot;
   
   return(lots);
}


/**
 * typeから適切な発注価格を生成する.
 * 待機注文の場合はStopLevelも考慮する.
 *
 * @param const int type 取引種別
 * @param const double price 発注価格
 *
 * @param double 生成された発注価格
 */
double UnitTest::CreateDummyPrice(const int type)
{
   double price = 0;
   double point = NormalizeDouble(MathRand() / 1000, 0) * _Point;
   if(_Digits % 2 == 1) {
      point *= 10;
   }
   point += MarketInfo(_Symbol, MODE_STOPLEVEL);
   
   switch(type) {
      case OP_BUY:       price = Ask;         break;
      case OP_SELL:      price = Bid;         break;
      case OP_BUYLIMIT:  price = Ask - point; break;
      case OP_SELLLIMIT: price = Bid + point; break;
      case OP_BUYSTOP:   price = Ask + point; break;
      case OP_SELLSTOP:  price = Bid - point; break;
   }

   return(price);
}


/**
 * priceとtypeから適切なSLを生成する.
 * StopLevelも考慮する.
 *
 * @param const int type 取引種別
 * @param const double price 発注価格
 *
 * @param double 生成されたランダムなSL
 */
double UnitTest::CreateDummySL(const int type,const double price)
{
   if(MathRand() % 2 == 0) return(0);
   
   double sl = 0.0;
   double point = NormalizeDouble(MathRand() / 1000, 0) * _Point;
   if(_Digits % 2 == 1) {
      point *= 10;
   }
   point += MarketInfo(_Symbol, MODE_STOPLEVEL);
   
   if(type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) {
      sl = price - point;
   }
   else if(type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) {
      sl = price + point;
   }
   
   return(sl);
}


/**
 * priceとtypeから適切なTPを生成する.
 * StopLevelも考慮する.
 *
 * @param const int type 取引種別
 * @param const double price 発注価格
 *
 * @param double 生成されたランダムなTP
 */
double UnitTest::CreateDummyTP(const int type,const double price)
{
   if(MathRand() % 2 == 0) return(0);
   
   double tp = 0.0;
   double point = NormalizeDouble(MathRand() / 1000, 0) * _Point;
   if(_Digits % 2 == 1) {
      point *= 10;
   }
   point += MarketInfo(_Symbol, MODE_STOPLEVEL);
   
   if(type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP) {
      tp = price + point;
   }
   else if(type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP) {
      tp = price - point;
   }
   
   return(tp);
}


#endif
