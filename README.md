# Terraform-Azure
Terraform-Azure for Aztek
![alt text](https://github.com/kfir25/Terraform-Azure/blob/main/kfir-aztek-arch.dra.png?raw=true)

מקרה לקוח:

הלקוח הינו חברת מוצר.

לחברת מוצר יש מוצר שהוא יכול להתקין ב- On-Prem או בענן. הלקוח שומר על אגנוסטיות המוצר ולכן הוא מעוניין להקים אותו על VMs גם בענן.

לאחרונה, החברה נכנסה גם לעולם של Azure, ויש לה כעת 10 לקוחות חדשים שרוצים לרכוש את המוצר ולהתקין אותו על חשבון ה- Azure שלהם.

לכן, החברה רוצה לייצר תהליך Continuous Delivery מסודר עבור הקמה אוטומטית של התשתיות ב- Azure, התשתית מבוססת IaaS.

 המוצר מכיל את הרכיבים הבאים:

    שרת WEB מסוג Windows עבור האפליקציה
    שרת SQL Server עבור בסיס הנתונים

 הלקוח מעוניין להקים תהליך CD מסודר מבוסס Terraform שיקים את התשתית עבור המוצר שלו, ותכלול את השרתים הנ"ל.

תהליך ה- CD לא אמור לטפל בהתקנת האפליקציה עצמה, או בהקמת בסיס הנתונים בתוך ה- SQL, או תהליכים אפליקטיביים אחרים.

דרישות נוספות שהתהליך צריך לתמוך:

אנחנו מחוייבים לSLA עבור הלקוח ולכן המערכת צריכה להיות תומכת ב- High Availability

המערכת צריכה להיות מוגנת על ידי רכיב Network Security Group של Azure, כך שרק הפורטים הרלוונטיים עבור גישה לאפליקציה ולבסיס הנתונים יהיו פתוחים.

תהליך ה- CD צריך לדעת לקבל פרמטרים כדי להתאים את ההקמה כל פעם ללקוח ספציפי, ולשינויים שעשויים להיות בערכים בין לקוח ללקוח.

