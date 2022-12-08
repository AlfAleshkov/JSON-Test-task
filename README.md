# JSON-Test-task
 JSON Test task<br />
<br />
Тестовое задание <br />
<br />
<b>Второй вопрос:</b><br />
<i>«2. Есть набор данных (артикул - цена), например:<br />
<br />
16605.3		1499р<br />
16605.4		1599р<br />
16608		999р<br />
и тд<br />
<br />
Вы их откуда то получили единожды. А дальше вам надо будет к ним постоянно обращаться из разных функций. Как вы будете их хранить (на период работы программы) и как по определнному артикулу получать цену? Написать в виде кода.»</i><br />

Наиболее логичным для этого считаю использование словарей, так же как и в Python'е, если не ошибаюсь их поддержка в Delphi появилась начиная с версий XE<br />
```Pascal
dict:TDictionary<string, integer>;
...
dict:=TDictionary<string, integer>.Create;
...
dict.Free;
```
где ```string``` - артикул, он же ключ, по которому можно обращаться так же как к индексу массива, а тип данных содержимого - ```integer```, ну или можно поставить ```Cardinal``` если отрицательные значения не нужны, или ```single``` если нужны знаки после запятой, ну или ```string``` если там же надо хранить "р."<br />
для записи нового значения в словарь используется метод ```Add```, например
```Pascal
dict.Add('16605.3',1499);
```
для чтения/записи в созданную ячейку, можно напрямую обращаться по индексу ```dict['16605.3']:=500;``` <br />
Либо для чтения пользоваться методом ```TryGetValue``` если нет уверенности, что значение с таким ключом есть в принципе<br />
Второй вариант, по-старинке, создать свой тип данных и сделать динамический массив из этих данных<br />
```Pascal
type
  TPriceData = Record
    sku:string;
    price:integer;
  End;
...
  prices:array of TPriceData;
...
// тогда простой вариант добавления нового значения, без проверки на существование ключа, будет выглядеть так
SetLength(prices,Length(prices)+1);
with prices[Length(prices)-1] do begin
  sku:='16003.5';
  price:=2380;
  end;
...
// поиск значения по артикулу
function GetPrice(sku:string; var price:integer;):Boolean;
var
  i:integer;
begin
  Result:=false;
  For i:=0 to Length(prices)-1 do begin
    if prices[i].sku = sku then begin
      price:=prices[i].price;
      Result:=true;
      Exit;
      end;
  end;
end;
```
можно обернуть в отдельный класс, но всё равно считаю этот вариант менее предпочтительным, потому что придется также написать ряд функций, которые будут проверять уникальность ключа, поиск по ключу, хорошо бы добавить внутренюю сортировку для повышения эффективности поиска по ключу, в общем по новой изобретать велосипед, который уже реализован в ```TDictionary```<br />
<br />
<b>Третий вопрос:</b><br />
«3. На форме уже есть FDConnection, FDQuery, он настроены. Вам надо с помощью FDQuery вставить в таблицу testTable (art, title, price) значения:<br />
16605.3		Щенячий патруль база спасателей	 	1499р<br />
16605.4		Щенячий патруль спасатель		1599р<br />
16608		Щенячий патруль гонщик			999р<br />
<br />
и вывести в результате количество вставленных строк или ошибку»<br />
<br />
```Pascal
var 
 RowsAffected:byte;
...
try
  RowsAffected:=0;
  FDQuery.SQL.Clear;
  FDQuery.ExecSQL('INSERT INTO testTable (art, title, price) VALUES (''16605.3'',''Щенячий патруль база спасателей'', ''1499р'')');
  RowsAffected:=RowsAffected+FDQuery.RowsAffected;
  FDQuery.ExecSQL('INSERT INTO testTable (art, title, price) VALUES (''16605.4'',''Щенячий патруль спасатель'', ''1599р'')');
  RowsAffected:=RowsAffected+FDQuery.RowsAffected;
  FDQuery.ExecSQL('INSERT INTO testTable (art, title, price) VALUES (''16608'',''Щенячий патруль гонщик'', ''999р'')');
  RowsAffected:=RowsAffected+FDQuery.RowsAffected;
  Memo.Lines.Add('Lines affected:'+IntToStr(RowsAffected));
except
  on E: EFDDBEngineException do
    Memo.Lines.Add('Error:'+e.Message);
end;
```
Или можно было через Bulk insert, но вот например FireBird его, увы, не поддерживает, а так был бы всего один INSERT
```
FDQuery.ExecSQL('INSERT INTO testTable (art, title, price) VALUES ( ... , ... , ... ),  ( ... , ... , ... ),  ( ... , ... , ... )');
```
