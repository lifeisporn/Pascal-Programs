uses crt;

const
  UserTextColor = 14;
  ComputerTextColor = 7;
  ErrorTextColor = 12;
  TaskTextColor = 13;
  AnswerTextColor = 10;
  MinElements = 3;
  MaxElements = 6;
  MaxKoeff = 4;

type
  abc = record
    a, b, c, d: smallint;
    error: boolean = false;
    constructor create(expr: string; CheckDuplicates: boolean := false);
  end;

constructor abc.Create(expr: string; CheckDuplicates: boolean);
var
  n, a, b, c, d: shortint;
begin
  // Проверяем ответ пользователя на полноту
  if CheckDuplicates then
    for var i := expr.Length downto 1 do
      if expr[i] = 'a' then a += 1
      else if expr[i] = 'b' then b += 1
      else if expr[i] = 'c' then c += 1
      else if expr[i] = 'd' then d += 1;
  
  expr := ' ' + expr + ' ';
  //writeln(expr);
  try
    if (a > 1) or (b > 1) or (c > 1) or (d > 1) then raise new Exception('Неполный ответ');
    
    // Для `a`
    for var i := 2 to expr.Length - 1 do
      if expr[i] = 'a' then
      begin
        if expr[i + 2] in ['+', '-'] then n := StrToInt(expr[i + 1])
        else n := StrToInt(expr[i + 1] + expr[i + 2]);
        if expr[i - 1] = '-' then Self.a -= n else Self.a += n;
      end;
    
    // Для `b`
    for var i := 2 to expr.Length - 1 do
      if expr[i] = 'b' then
      begin
        if expr[i + 2] in ['+', '-'] then n := StrToInt(expr[i + 1])
        else n := StrToInt(expr[i + 1] + expr[i + 2]);
        if expr[i - 1] = '-' then Self.b -= n else Self.b += n;
      end;
    
    // Для `c`
    for var i := 2 to expr.Length - 1 do
      if expr[i] = 'c' then
      begin
        if expr[i + 2] in ['+', '-'] then n := StrToInt(expr[i + 1])
        else n := StrToInt(expr[i + 1] + expr[i + 2]);
        if expr[i - 1] = '-' then Self.c -= n else Self.c += n;
      end;
    
    // Для `d`
    for var i := 2 to expr.Length - 1 do
      if expr[i] = 'd' then
      begin
        if expr[i + 2] in ['+', '-'] then n := StrToInt(expr[i + 1])
        else n := StrToInt(expr[i + 1] + expr[i + 2]);
        if expr[i - 1] = '-' then Self.d -= n else Self.d += n;
      end;
  except
    Self.error := true;
  end;
end;

procedure wr(params args: array of object);
begin
  if args[0] = 'err' then TextColor(ErrorTextColor)
  else if args[0] = 'task' then TextColor(TaskTextColor)
  else if args[0] = 'common' then TextColor(ComputerTextColor)
  else if args[0] = 'answer' then TextColor(AnswerTextColor);
  
  {for var i := 0 to args.Length - 2 do args[i] := args[i + 1];
  SetLength(args, args.Length - 1);}
  args[0] := '  ';
  
  write(args);
  
  TextColor(UserTextColor);
end;

procedure wrln(params args: array of object);
begin
  wr(args);
  writeln;
end;

function GetTask: string;
  function GetLetter: char;
  begin
    if random(3) = 0 then result := #0
    else result := Chr(random(97, 99));
  end;
  
  function GetKoeff: char;
  begin
    result := IntToStr(random(1, MaxKoeff))[1];
    if result = '1' then result := #0;
  end;
  
  function GetSign: char;
  begin
    if random(2) = 0 then result := '-'
    else result := '+';
  end;
  
  function GetElement: string;
  begin
    result := GetKoeff + GetLetter;
    if result = #0#0 then result := GetElement;
  end;
  
  function GetReplace(first: boolean; var opened: byte; last: boolean): string;
  label again;
  begin
    again:    
    case random(1, 4) of
      1: result := '+';
      2: result := '-';
      3: result := ')';
      4: result := '(';
    end;
    
      // Нельзя первыми + и )
    if first and (result[1] in ['+', ')']) then goto again;
    
      // Избегаем лишних проверок
    if (result[1] in ['+', '-']) and not (last or first) then exit;
    
      // Проверяем правильность открывающей скобки и добавляем знаки
    if result[1] = '(' then 
    begin
      if last then goto again;
      
      opened += 1;
      
      if random(2) = 0 then 
        if not first then result := '+' + result 
        else
      else result := '-' + result;
      
      if random(2) = 0 then result := copy(result, 1, 1) + random(2, MaxKoeff).ToString + copy(result, 2, result.Length);
      
      if random(2) = 0 then result += '-';
      
        // Избегаем лишних проверок
      exit;
    end;
    
      // Проверяем закрывающую скобку
    if result[1] = ')' then
    begin
      if opened > 0 then opened -= 1 else goto again;
      
      if not last then
        if random(2) = 0 then result += '-' else result += '+';
    end;
    
    if last and ((result[1] in ['+', '-']) or (opened > 0)) then result := '';
  end;

var
  c, n, opened: byte;
begin
  result := '_';
  c := random(MinElements, MaxElements);
  opened := 0;
  
  // Добавляем плейсхолдеры
  for var i := 1 to c do result += GetElement + '_';
  
  // Заменяем плейсхолдеры на +,-,0-9,(,),''
  n := pos('_', result);
  while n <> 0 do
  begin
    //write('     opened: ', opened, '->');
    result := copy(result, 1, n - 1) + GetReplace(n = 1, opened, pos('_', result, n + 1) = 0) + copy(result, n + 1, result.Length);
    //writeln(opened);
    n := pos('_', result);
  end;
  
  // Закрываем скобки (заново проверим количество на всякий случай)
  repeat
    opened := 0;
    
    for var i := 1 to result.Length do
    begin
      if result[i] = '(' then opened += 1
      else if result[i] = ')' then opened -= 1;
      
      if opened < 0 then 
      begin
				result := GetTask;
				break;
			end;
    end;
    
    while opened > 0 do 
    begin
      result += ')';
      opened -= 1;
    end;
    
  until opened = 0;
  
  result := result.Replace('++', '+');
  result := result.Replace('--', '-');
  result := result.Replace('-+', '-');
  result := result.Replace('+-', '-');
  result := result.Replace(' ', '');
  result := result.Replace(#0, '');
  
  // Добавляем минус в скобку с одним элементом положительным
  //write('                 ', result);
  result := regex.Replace(result, '(?<=\()\d*[a-z]*(?=\))', '-$0');
  //writeln(' => ', result);
end;

function OpenBrackets(content: string; reverse: boolean := false; multiplier: byte := 1): string;
var
  NewContent, bufCont: string;
  k, left, right, num: byte;
  NeedReverse: boolean;
begin
  if multiplier = 0 then 
  begin
    result := '0';
    exit;
  end;
  //writeln('IN: ', content);
    // Определяем скобки и рекурсивно раскрываем, если есть
  while pos('(', content) > 0 do
  begin
    bufCont := content;
    
    left := LastPos('(', bufCont); // Берём самую вложенную скобку
    right := Pos(')', bufCont, left); // И её закрывающую пару
    
    NeedReverse := false;
    
    if left > 1 then // Если скобка не в начале примера, проверяем наличие минуса перед ней
      if bufCont[left - 1] = '-' then 
      begin
        NeedReverse := true;
        // content := copy(content, 1, left - 2) + copy(content, left, content.Length);
      end;
      //wrln('err', content);halt;
    
    num := StrToInt(bufCont[right + 1] + bufCont[right + 2]); // Двузначный множитель, стоит справа для удобства парсинга
    
    bufCont := copy(bufCont, left + 1, right - left - 1); // Берём содержимое в этих скобках
    
    if NeedReverse then k := 2 else k := 1; // Отступ из-за знака
    //writeln('    OPENING: ', bufCont, ' ', needreverse, ' ', multiplier);
    //write('    ');
    bufCont := OpenBrackets(bufCont, NeedReverse, num * multiplier);
    //writeln('    OUT: ', bufcont);
    {
    if (bufCont[1] = '-') and (k = 1) then 
    begin
      k := 2;
      bufcont := '+' + copy(bufcont, 2, bufcont.Length);
      end;}
    
    content := copy(content, 1, left - k) + bufCont + copy(content, right + 3, content.Length); //+3 - скобка и двузначный множитель
    //writeln('INSERTED: ', content);
  end;
  
  if not (content[1] in ['-', '+']) then content := '+' + content;
  
  // Меняем знаки на противоположные
  if reverse then
  begin
    content := content.Replace('+', '!');
    content := content.Replace('-', '+');
    content := content.Replace('!', '-');
  end;
  
  NewContent := content;
  
  // Умножаем коэффициенты
  var i: byte = 1;
  var bufK: byte;
  var bufS: string;
  if Multiplier <> 1 then
    repeat
      try
        if (NewContent[i] in ['0'..'9']) and (NewContent[i + 1] in ['0'..'9']) then 
        begin
          bufK := StrToInt(NewContent[i] + NewContent[i + 1]) * Multiplier;
          bufS := bufK.ToString;
          if bufK < 10 then bufS := 0 + bufS; // Делаем коэффициент двузначным
          NewContent[i] := '_';
          NewContent[i + 1] := '_';
          NewContent := NewContent.Replace('__', bufS);
          // i += 2; // Пропускаем вторую цифру и знак
        end;
      except
        break;
      end;
      i += 1;
    until i = NewContent.Length;
  
  if NewContent[1] in ['a'..'z'] then NewContent := '+' + NewContent;
  
  result := NewContent;
 // writeln('   -> ', result);
end;

function PrepareExpr(expr: string): string;
var
  k, j: shortint;
  prepared: string;
  changed: boolean;
begin
  expr := ' ' + trim(expr) + ' '; // Входит с пробелом в конце из-за странного поведения, поэтому trim
  
  // Добавим к пустым коэффициентам букву `d`
  expr := regex.Replace(expr, '\d+(?=\+|\-|\)|\s)', '$0d');
  
  // Заменяем пустые коэффициенты на 1
  expr := regex.Replace(expr, '(?<=\+|\-|\(|\s)[a-z\(]', '1$0');
  
  // Делаем коэффициенты двузначными
  expr := regex.Replace(expr, '(?<=\+|\-|\(|\s)\d(?=[a-z\(])', '0$0');
  
  // Меняем местами коэффициенты и буквы
  expr := regex.Replace(expr, '(\d+)([a-z](?!=\-\+))', '$2$1');
  
  // Меняем местами коэффициенты и скобки
  repeat
    changed := false;
    
    for var i := 1 to expr.Length - 1 do
      if (expr[i] in ['0'..'9']) and (expr[i + 1] = '(') then
      begin
        k := 1;
        
        for j := i + 4 to expr.Length do // первые 3 символа - скобка, знак и буква
        begin
          if expr[j] = ')' then k -= 1
          else if expr[j] = '(' then k += 1;
          if k = 0 then break; // Нашли парную скобку, i + 1, j - позиции скобок
        end;
        
        expr := copy(expr, 1, i - 1) + copy(expr, i + 1, j - i) + expr[i] + copy(expr, j + 1, expr.Length);
        
        changed := true;
        break;
      end;
  until not changed;
  
  prepared := OpenBrackets(expr);
  if prepared[1] = '+' then delete(prepared, 1, 1);
  
  result := regex.Replace(prepared, '0(?=\d)', ''); // Убираем ведущие нули за ненадобностью
end;

function GetAnswer(expr: string): string;
var
  a, b, c, d: string;
  exprRec: abc;

label ex;
begin
  exprRec := abc.Create(expr);
  
  if exprRec.error then
  begin
    wrln('error', 'ОШИБКА ПРИ СОЗДАНИИ ЗАДАНИЯ!');
    readln;
    halt;
  end;  
  
  if exprRec.a <> 0 then 
    if exprRec.a < 0 then a := exprRec.a.ToString + 'a'
    else a := '+' + exprRec.a.ToString + 'a';
  
  if exprRec.b <> 0 then 
    if exprRec.b < 0 then b := exprRec.b.ToString + 'b'
    else b := '+' + exprRec.b.ToString + 'b';
  
  if exprRec.c <> 0 then 
    if exprRec.c < 0 then c := exprRec.c.ToString + 'c'
    else c := '+' + exprRec.c.ToString + 'c';
  
  if exprRec.d <> 0 then 
    if exprRec.d < 0 then d := exprRec.d.ToString
    else d := '+' + exprRec.d.ToString;
  //-a+b+c
  //-a+b-c
  //-a-b+c
  result := a + b + c + d;
  
  if result = '' then 
  begin
    result := '0';
    exit;
  end;
  
  if (exprRec.a > 0) or (exprRec.a < 0) and (exprRec.b < 0) and (exprRec.c < 0) and (exprRec.d < 0) then goto ex;
  
  if exprRec.b > 0 then result := b + a + c + d 
  else if exprRec.c > 0 then result := c + a + b + d
  else result := d + a + c + b;
  
  ex:
  result := trim(regex.Replace(' ' + result + ' ', '(?<=\s|\+|\-)1(?=[a-z])', ''));
  if result[1] = '+' then result := copy(result, 2, result.Length);
end;

var
  input, task, prepared: string;
  errors: byte;
  count: integer;
  answer: abc;

label count_input, againt;

begin
  // Начальные настройки
  TextColor(UserTextColor);
  
  // Установка количества
  count_input:
  wr('common', 'Введите количество примеров 1-100: ');
  readln(input);
  
  try
    count := StrToInt(input);
  except
    count := 0;
  end;
  
  if not (count in [1..100]) then 
  begin
    wrln('err', 'Только в пределах 1-100!!!' + Chr(10));
    goto count_input;
  end;
  
  writeln;
  
  errors := 0;
  
  // Генерируем примеры
  for var CurTask := 1 to count do
  begin
    againt:
    repeat
      task := GetTask;
    until pos('(', task) > 0;
    
    
    
    
    
    //task := '(4-c-4(-3c+3+2b+3(-2-3b)))';
    
    
    
    
    
    
    
    prepared := PrepareExpr(task + ' '); // + ' ' -> Иначе будет меняться task внутри функции (хз как...)
    
    task := task.Replace('-', ' - ');
    task := task.Replace('+', ' + ');
    task := task.Replace('( - ', '(-');
    task := task.Replace('( + ', '(');
    task := trim(task);
    
    //wrln('common', task, ' = ', GetAnswer(prepared)); 
    //continue;
    answer := abc.Create(prepared);
    
    if answer.error then
    begin
      wrln('error', 'ОШИБКА ПРИ СОЗДАНИИ ЗАДАНИЯ!');
      readln;
      halt;
    end;
    
    // Только двузначные коэффициенты!
    if (answer.a > 99) or (answer.b > 99) or (answer.c > 99) or (answer.d > 99) then goto againt;
    
    //halt;
    repeat
      wr('common', 'Задание ', CurTask, ': ');
      wr('task', task);
      wr('common', ' = ');
      
      readln(input);
      
      if (input.Length < 1) or (pos('(', input) + pos(')', input) > 0) then
      begin
        wrln('err', 'Неверно!' + Chr(10));
        errors += 1;
        
        continue;
      end;
      
      if input = '?' then 
      begin
        wrln('answer', GetAnswer(prepared));
        continue;
      end
      else
      begin
        input := lowercase(input).Replace(' ', '');
        
        if abc.Create(PrepareExpr(input), true) <> answer then
        begin
          wrln('err', 'Неверно!' + Chr(10));
          errors += 1;
          
          continue;
        end;
      end;
      
      wrln('answer', 'Верно!' + Chr(10));
      
      break;
    until false;
  end;
  
  writeln;
  wrln('common', 'Ошибок: ', errors + Chr(10));
  // Сообщение о завершении программы белым цветом
  TextColor(15);
end.