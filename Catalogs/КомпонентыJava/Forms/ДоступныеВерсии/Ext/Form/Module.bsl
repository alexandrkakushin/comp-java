﻿
///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не Параметры.Свойство("Компонента", Компонента) Тогда
		Сообщить(НСтр("ru = 'Не выбрана компонента. Действие отменено'"));
		
		Возврат;
	КонецЕсли;
	
	Для Каждого Версия Из КомпонентыJava.ДоступныеВерсии(Компонента) Цикл
		НоваяСтрока = Версии.Добавить();
		
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Версия);
		Если Компонента.Версия = НоваяСтрока.Номер Тогда
			НоваяСтрока.Текущая = Истина;			
		КонецЕсли;
	КонецЦикла;
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПерейтиНаВерсию(Команда)
	
	ТекущиеДанные = Элементы.Версии.ТекущиеДанные;
	Если ТекущиеДанные = Неопределено Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Необходимо выбрать версию компоненты'"));
		Возврат;		
	КонецЕсли;
	
	Если Не ТекущиеДанные.Текущая Тогда	
		КомпонентыJavaВызовСервера.ПерейтиНаВерсию(Компонента, 
			ТекущиеДанные.Номер);
			
		Для Каждого ЭлементКоллеции Из Версии Цикл
			ЭлементКоллеции.Текущая = Ложь;		
		КонецЦикла;			
		ТекущиеДанные.Текущая = Истина;
		
		Оповестить(КомпонентыJavaКлиент.Событие_УстановкаВерсии());
	Иначе
		ПоказатьПредупреждение(,
			НСтр("ru = 'Выбранная версия компоненты уже установлена'"));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(ЭтаФорма)
	
	ЭтаФорма.Заголовок = Строка(ЭтаФорма.Компонента) + " - Доступные версии";
	
КонецПроцедуры

#КонецОбласти