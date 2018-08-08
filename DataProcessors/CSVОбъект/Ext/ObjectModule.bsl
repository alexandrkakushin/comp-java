﻿
///////////////////////////////////////////////////////////////////////////////
// ДАННЫЕ ФАЙЛА

#Область ДанныеФайлы

// Чтение данных из CSV-файла
//
// Параметры:
//  ПредставлениеМодели	 - Строка - 
//  НастройкаПолей		 - Структура - 
//  ОписаниеОшибок		 -Строка - 
// 
// Возвращаемое значение:
//  Массив, ТаблицаЗначений, ТабличныйДокумент - Представление модели
//
Функция Прочитать(ПредставлениеМодели = Неопределено, НастройкаПолей = Неопределено, 
	ОписаниеОшибок = Неопределено) Экспорт
	
	Если ПредставлениеМодели = Неопределено Тогда
		ПредставлениеМодели = ПредставлениеМодели(, ОписаниеОшибок);	
	КонецЕсли;
	
	АдресВоВременном = Неопределено;
	Если ЭтоАдресВременногоХранилища(Источник) Тогда
		АдресВоВременном = Источник;
	Иначе
		Файл = Новый Файл(Источник);
		Если Файл.Существует() Тогда
			АдресВоВременном = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(Источник));
		КонецЕсли;		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(АдресВоВременном) Тогда
		ОписаниеОшибок = НСтр("ru = 'Неверно указан источник'");
	КонецЕсли;
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла(".csv");
	Данные = ПолучитьИзВременногоХранилища(АдресВоВременном);	
	Данные.Записать(ИмяВременногоФайла);
		
	Возврат ПредставлениеМоделиИзXDTO(
		ДанныеXDTO(ИмяВременногоФайла, Кодировка, Разделитель, ОписаниеОшибок),
		ПредставлениеМодели,
		НастройкаПолей);
		
КонецФункции

Функция ДанныеXDTO(CsvФайл, Кодировка, Разделитель, ОписаниеОшибки = Неопределено) Экспорт
	
	ДанныеXDTO = Неопределено;
	
	Прокси = ПроксиКомпоненты(ОписаниеОшибки);
	Если Прокси <> Неопределено Тогда
		ДанныеXDTO = Прокси.parseCsv(CsvФайл, XMLСтрока(Кодировка), Разделитель);
		ОписаниеОшибки = ДанныеXDTO.error; 
		УдалитьФайлы(CsvФайл);
	Иначе
		ОписаниеОшибки = НСтр("ru = 'Компонента импорта не доступна'");
	КонецЕсли;			
	
	Возврат ДанныеXDTO;
		
КонецФункции

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// ПРЕДСТАВЛЕНИЕ МОДЕЛИ

#Область ПредставлениеМодели

// Возвращает представление модели
//
// Параметры:
//  Имя	 - Строка - возможные значения "МассивСтруктур", "ТаблицаЗначений", "ТабличныйДокумент", "Матрица"
// 
// Возвращаемое значение:
//  Строка - 
//
Функция ПредставлениеМодели(Имя = Неопределено, ОписаниеОшибок = Неопределено) Экспорт

	Если Не ЗначениеЗаполнено(Имя) Тогда
		Имя = "МассивСтруктур";
	КонецЕсли;
	
	Найденное = ВозможныеПредставленияМодели().Найти(НРег(Имя));
	Если Найденное = Неопределено Тогда
		ОписаниеОшибок = НСтр("ru = 'Представление модели не найдено!'");
	КонецЕсли;
	
	Возврат НРег(Имя);	
	
КонецФункции

// Возможные представления модели
// 
// Возвращаемое значение:
//  Массив - 
//
Функция ВозможныеПредставленияМодели()
	
	Значения = Новый Массив();
	Значения.Добавить(НРег("МассивСтруктур"));
	Значения.Добавить(НРег("ТаблицаЗначений"));
	Значения.Добавить(НРег("ТабличныйДокумент"));
	Значения.Добавить(НРег("Матрица"));
	
	Возврат Значения;
	
КонецФункции

// Преобразование модели в "табличное" представление

Функция ПредставлениеМоделиИзXDTO(ДанныеXDTO, ПредставлениеМодели = Неопределено, НастройкаПолей = Неопределено) Экспорт
	
	Результат = Неопределено;	
	Если ДанныеXDTO = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	// Таблица значений
	Если ПредставлениеМодели = ПредставлениеМодели("ТаблицаЗначений") Тогда
		Результат = МодельВТаблицуЗначений(ДанныеXDTO, НастройкаПолей);	
		
	// Массив структур
	ИначеЕсли ПредставлениеМодели = ПредставлениеМодели("МассивСтруктур") Тогда
		Результат = МодельВМассивСтруктур(ДанныеXDTO, НастройкаПолей);
		
	// Табличный документ
	ИначеЕсли ПредставлениеМодели = ПредставлениеМодели("ТабличныйДокумент") Тогда
		Результат = МодельВТабличныйДокумент(ДанныеXDTO, НастройкаПолей);
		
	// Матрица
	ИначеЕсли ПредставлениеМодели = ПредставлениеМодели("Матрица") Тогда
		Результат = МодельВМатрицу(ДанныеXDTO);
		
	КонецЕсли;		
		
	Возврат Результат;
	
КонецФункции

Функция МодельВТаблицуЗначений(ОбъектXDTO, НастройкаПолей = Неопределено) 
	
	Импорт = Новый ТаблицаЗначений();	
	ИсключатьПервуюСтроку = Ложь;
	
	// Колонки		
	ОтображаемыеПоля = Новый Массив();
	ПрименитьНастройкуПолей(ОбъектXDTO, НастройкаПолей, ОтображаемыеПоля, ИсключатьПервуюСтроку);
	Для Каждого ОтображаемоеПоле Из ОтображаемыеПоля Цикл
		Импорт.Колонки.Добавить(ОтображаемоеПоле);	
	КонецЦикла;
	
	// Строки
	КоличествоКолонок = Импорт.Колонки.Количество();	
	Для Индекс = ?(ИсключатьПервуюСтроку, 1, 0) По ОбъектXDTO.rows.row.Количество() - 1 Цикл
		СтрокаXDTO  = ОбъектXDTO.rows.row[Индекс];
		НоваяСтрока = Импорт.Добавить();	
		Для НомерПоля = 0 По КоличествоКолонок - 1 Цикл
			Если НомерПоля < СтрокаXDTO.cell.Количество() Тогда
				ЯчейкаXDTO = СтрокаXDTO.cell[НомерПоля];
				НоваяСтрока.Установить(НомерПоля, ЯчейкаXDTO.value);
			КонецЕсли;
		КонецЦикла;		
	КонецЦикла;
			
	Возврат Импорт;	
		
КонецФункции

Функция МодельВМассивСтруктур(ОбъектXDTO, НастройкаПолей = Неопределено) 
	
	Импорт  = Новый Массив();	
	Колонки = Новый Структура();
	
	ИсключатьПервуюСтроку = Ложь;
		
	// Колонки
	ОтображаемыеПоля = Новый Массив();
	ПрименитьНастройкуПолей(ОбъектXDTO, НастройкаПолей, ОтображаемыеПоля, ИсключатьПервуюСтроку);
	Для Каждого ОтображаемоеПоле Из ОтображаемыеПоля Цикл
		Колонки.Вставить(ОтображаемоеПоле);	
	КонецЦикла;
	ДоступныеПоля = Новый ФиксированнаяСтруктура(Колонки);
	
	// Строки
	Для Индекс = ?(ИсключатьПервуюСтроку, 1, 0) По ОбъектXDTO.rows.row.Количество() - 1 Цикл
		СтрокаXDTO  = ОбъектXDTO.rows.row[Индекс];
		НоваяСтрока = Новый Структура(ДоступныеПоля);
		НомерПоля = 0;
		Для Каждого Поле Из НоваяСтрока Цикл
			Если НомерПоля < СтрокаXDTO.cell.Количество() Тогда
				НоваяСтрока[Поле.Ключ] = СтрокаXDTO.cell[НомерПоля].value;
				НомерПоля = НомерПоля + 1;
			КонецЕсли;
		КонецЦикла;
		Импорт.Добавить(НоваяСтрока);
	КонецЦикла;
				
	Возврат Импорт;		
	
КонецФункции

Функция МодельВТабличныйДокумент(ОбъектXDTO, НастройкаПолей = Неопределено) 
	
	Импорт = Новый ТабличныйДокумент();
	
	ИсключатьПервуюСтроку = Ложь;
		
	Колонки = Новый Структура();
	ОбластьВывода = Импорт.ПолучитьОбласть(1, 1, 1, ОбъектXDTO.fields.field.Количество());
	
	// Колонки
	ОтображаемыеПоля = Новый Массив();
	ПрименитьНастройкуПолей(ОбъектXDTO, НастройкаПолей, ОтображаемыеПоля, ИсключатьПервуюСтроку);
	Индекс = 1;
	Для Каждого ОтображаемоеПоле Из ОтображаемыеПоля Цикл
        ОбластьЗаполнения = ОбластьВывода.Область(1, Индекс, 1, Индекс);
        ОбластьЗаполнения.Параметр   = ОтображаемоеПоле;
        ОбластьЗаполнения.Заполнение = ТипЗаполненияОбластиТабличногоДокумента.Параметр;		
		Колонки.Вставить(ОтображаемоеПоле);
		Индекс = Индекс + 1;	
	КонецЦикла;
	ДоступныеПоля = Новый ФиксированнаяСтруктура(Колонки);
		
	// Поля таблицы
	НоваяСтрока = Новый Структура(ДоступныеПоля);
	Для Каждого Поле Из НоваяСтрока Цикл
		НоваяСтрока[Поле.Ключ] = Поле.Ключ;
	КонецЦикла;
    ОбластьВывода.Параметры.Заполнить(НоваяСтрока);
    Импорт.Вывести(ОбластьВывода);	
	
	// Строки	
	Для Индекс = ?(ИсключатьПервуюСтроку, 1, 0) По ОбъектXDTO.rows.row.Количество() - 1 Цикл
		СтрокаXDTO  = ОбъектXDTO.rows.row[Индекс];
		НоваяСтрока = Новый Структура(ДоступныеПоля);
		НомерПоля = 0;
		Для Каждого Поле Из НоваяСтрока Цикл
			Если НомерПоля < СтрокаXDTO.cell.Количество() Тогда
				НоваяСтрока[Поле.Ключ] = СтрокаXDTO.cell[НомерПоля].value;
				НомерПоля = НомерПоля + 1;
			КонецЕсли;
		КонецЦикла;				
		
        ОбластьВывода.Параметры.Заполнить(НоваяСтрока);
        Импорт.Вывести(ОбластьВывода);		
	КонецЦикла;
	
	Возврат Импорт;
		
КонецФункции

Функция МодельВМатрицу(ОбъектXDTO) 
	
	Импорт  = Новый Массив();	
	
	// Строки
	Для Каждого СтрокаXDTO Из ОбъектXDTO.rows.row Цикл
		НоваяСтрока = Новый Массив();
		
		Для Индекс = 0 По ОбъектXDTO.fields.field.Количество() - 1 Цикл
			Если Индекс < СтрокаXDTO.cell.Количество() Тогда
				НоваяСтрока.Добавить(СтрокаXDTO.cell[Индекс].value);
			КонецЕсли;
		КонецЦикла;		
		
		Импорт.Добавить(НоваяСтрока);
	КонецЦикла;
			
	Возврат Импорт;		
	
КонецФункции

// Применение настройки полей к выводимой информации
//
// Параметры:
//  ОбъектXDTO				 - 	 - 
//  НастройкаПолей			 - 	 - 
//  ОтображаемыеПоля		 - 	 - 
//  ИсключатьПервуюСтроку	 - 	 - 
//
Процедура ПрименитьНастройкуПолей(ОбъектXDTO, Знач НастройкаПолей, ОтображаемыеПоля, ИсключатьПервуюСтроку = Ложь)
	
	Если ОбъектXDTO = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ОтображаемыеПоля = Новый Массив();	
	ИменаВПервойСтроке = Ложь;
	ИменаПолей = Неопределено;
	
	// Колонки		
	ИспользоватьНастройкуПолей = (НастройкаПолей <> Неопределено);
	Если ИспользоватьНастройкуПолей Тогда
		Если НастройкаПолей.Свойство("ИменаВПервойСтроке") Тогда 
			ИменаВПервойСтроке = НастройкаПолей.ИменаВПервойСтроке;
		КонецЕсли;		
		Если НастройкаПолей.Свойство("ИсключатьПервуюСтроку") Тогда 
			ИсключатьПервуюСтроку = НастройкаПолей.ИсключатьПервуюСтроку;
		КонецЕсли;
		ИменаПолей = НастройкаПолей.Имена;
	КонецЕсли;
	
	Если ИменаВПервойСтроке Тогда
		ИсключатьПервуюСтроку = Истина;
		Если ОбъектXDTO.rows.row.Количество() > 0 Тогда
			Для Каждого ЯчейкаXDTO Из ОбъектXDTO.rows.row[0].cell Цикл
				ОтображаемыеПоля.Добавить(ЯчейкаXDTO.value);	
			КонецЦикла;
		КонецЕсли;
	Иначе
		КоличествоПолей = ?(ИспользоватьНастройкуПолей, НастройкаПолей.Имена.Количество(), 0);			
		Для Индекс = 0 По ОбъектXDTO.fields.field.Количество() - 1 Цикл
			ПолеXDTO = ОбъектXDTO.fields.field[Индекс];
			ИмяПоля  = ПолеXDTO.name;
			Если ИспользоватьНастройкуПолей Тогда
				Если Индекс < КоличествоПолей Тогда
					ИмяПоля = ИменаПолей[Индекс];
				КонецЕсли;
			КонецЕсли;
			ОтображаемыеПоля.Добавить(ИмяПоля);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Область СлужебныеПроцедурыИФункции

Функция ПроксиКомпоненты(ОписаниеОшибки = Неопределено)
	
	Прокси = КомпонентыJavaПовтИсп.ПроксиКомпоненты(
		Справочники.КомпонентыJava.importtable, ОписаниеОшибки);
		
	Возврат Прокси;
	
КонецФункции

#КонецОбласти