# comp-java

Конфигурация для расширения возможностей платформы 1С:Предприятие 8.3

Для подключения доступны следующие компоненты:
<ul>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-sftpclient">SFTP-клиент</a>  
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-jmsclient">JMS-клиент</a>
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-emailvalidator">E-mail валидатор</a>
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-logger">Логгер</a>
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-regex">Регулярные выражения</a>
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-sshclient">SSH-клиент</a>
  </li>  		
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-ldapclient">LDAP-клиент</a>
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-excelclient">Excel-клиент</a>
  </li>
  <li>
    <a href = "https://github.com/alexandrkakushin/comp-java-compress">Работа с архивами</a>
  </li>  
</ul>

## Внедрение
<p>Для внедрения подсистемы необходимо в режиме Конфигуратор выполнить следующие действия:</p>
<ul>
  <li>Конфигурация -> Открыть конфигурацию</li>
  <li>Конфигурация -> Сравнить, объединить с конфигурацией из файла, выбор CF-файла</li>
  <li>В появившемся диалоговом окне будет вопрос о постановке конфигурации на поддержку. 
    На Ваше усмотрение, но рекомендуется поставить на поддержку</li>
</ul>
<p>Если конфигурацию ставите на поддержку, необходимо сделать еще пару шагов</p>
<ul>
  <li>В окне "Сравнение, объединение" убрать флажок с поля "Версия" (Свойства -> Версия) основной конфигурации, затем "Выполнить"</li>
  <li>В окне "Настройка правил поддержки" оставить все по умолчанию и нажать "ОК"</li>
</ul>
<p>После внедрения рекомендуется в режиме 1С:Предприятие установить значение константы JAVA_HOME, 
  если нет JRE, то самое время установить данное ПО. 
<p>  
  Для установки константы JAVA_HOME откройте форму списка справочника "Компоненты Java",
  внизу щелкните по кнопке "...", далее выберите одну из доступных JRE или установите произвольное значение, 
  например, "C:\Program Files\OpenJDK\jdk-11.0.6.10-hotspot"
</p>  

## Подключение компонент

Для подключения компонент рекомендуется добавить серверный общий модуль, например **КомпонентыJavaAPI**

Компоненты не хранятся в конфигурации, для их получения необходимо Интернет-соединение. Jar-файлы хранятся в релизах самих компонент.

Ниже приведен пример подключения компоненты "Логгер"

``` 1С:Enterprise

///////////////////////////////////////////////////////////////////////////////
// Компоненты

#Область Компоненты

// "Объект" Логгер
//
// Параметры:
//  InMemory - Булево - 
//  ИмяФайла - Строка, Неопределено - Имя файла БД
// 
// Возвращаемое значение:
//  ОбработкаОбъект - ОбработкаОбъект
//
Функция Логгер(InMemory = Ложь, Знач ИмяФайла = Неопределено) Экспорт
	
	Объект = ИнтерфейсКомпоненты("comp-java-logger");
			
	Объект.InMemory = InMemory;
	
	Если Не InMemory Тогда		
		Если ПустаяСтрока(ИмяФайла) Тогда
			ВызватьИсключение НСтр("ru = 'Не задано имя файла для хранения логов'");
		КонецЕсли;
		Объект.ИмяФайла = ИмяФайла;	
	КонецЕсли;
	
	Объект.Инициализировать();
		
	Возврат Объект;
	
КонецФункции

#КонецОбласти

Функция ИнтерфейсКомпоненты(Репозиторий)
	
	Компонента = КомпонентыJava.КомпонентаПоРепозиторию(Репозиторий);
	Если Не ЗначениеЗаполнено(Компонента) Тогда
		ОписаниеОшибки = Неопределено;
		Если Не КомпонентыJava.УстановитьКомпоненту(Репозиторий, ОписаниеОшибки) Тогда
			ВызватьИсключение ОписаниеОшибки;			
		КонецЕсли;
				
		Компонента = КомпонентыJava.КомпонентаПоРепозиторию(Репозиторий);
	КонецЕсли;
	
	Возврат КомпонентыJava.Интерфейс(Компонента);	
	
КонецФункции
```

В дальнейшем для получения интерфеса "Логгера" достаточно использовать вызов 

``` 1С:Enterprise
КомпонентыJavaAPI.Логгер(Ложь, ФайлЛога("ПостроениеОтчетов"));
```

Более подробное описание в README компонент