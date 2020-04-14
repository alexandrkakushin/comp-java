﻿
///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Параметры.Ключ) Тогда
		ВызватьИсключение НСтр("ru = 'Запрещено создавать новые компоненты в режиме 1С:Предприятие'");
	КонецЕсли;
	
	Компонента = Объект.Ссылка;
	
	УправлениеФормой(ЭтаФорма);
		
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПроверитьДоступностьКомпоненты();
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Запустить(Команда)

	ОписаниеОшибки = Неопределено;
	Если НЕ КомпонентыJavaВызовСервера.ЗапуститьКомпоненту(Компонента, ОписаниеОшибки) Тогда
		ПоказатьПредупреждение(, ОписаниеОшибки);
	Иначе
		ПодключитьОбработчикОжидания("ПроверитьДоступностьКомпоненты", 2, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Остановить(Команда)
	
	КомпонентыJavaВызовСервера.ОстановитьКомпоненту(Компонента);
	ПодключитьОбработчикОжидания("ПроверитьДоступностьКомпоненты", 2, Истина);
		
КонецПроцедуры

&НаКлиенте
Процедура Проверить(Команда)
	
	ПроверитьДоступностьКомпоненты();
	
КонецПроцедуры

&НаКлиенте
Процедура ИсторияИзменений(Команда)

	ИсторияИзменений = ?(КомпонентаДоступна, 
		КомпонентыJavaВызовСервера.ИсторияИзмененийКомпоненты(Компонента), Неопределено);
		
	Если ИсторияИзменений <> Неопределено Тогда
		ОткрытьФорму("Справочник.КомпонентыJava.Форма.ИсторияИзменений", 
			Новый Структура("ИсторияИзменений", ИсторияИзменений));
	КонецЕсли;
		
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПроверитьДоступностьКомпоненты() Экспорт
	
	ТекущееСостояние = КомпонентаДоступна;		
	КомпонентаДоступна = КомпонентыJavaВызовСервера.КомпонентаДоступна(Компонента);
	
	ВерсияКомпоненты = ?(КомпонентаДоступна, КомпонентыJavaВызовСервера.ВерсияКомпоненты(Компонента), "");
				
	УправлениеФормой(ЭтаФорма);
		
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(ЭтаФорма)
	
	Объект = ЭтаФорма.Объект;
	
	Элементы = ЭтаФорма.Элементы;	
	Элементы.КомандаЗапустить.Доступность = НЕ ЭтаФорма.КомпонентаДоступна;
	Элементы.КомандаОстановить.Доступность = ЭтаФорма.КомпонентаДоступна;
	Элементы.ИсторияИзменений.Видимость = ЭтаФорма.КомпонентаДоступна;
		
КонецПроцедуры

#КонецОбласти