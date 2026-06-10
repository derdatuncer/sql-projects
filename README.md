# 🎓 BLM4522 - Ağ Tabanlı Paralel Dağıtım Sistemleri

![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft%20sql%20server&logoColor=white)
![ETL](https://img.shields.io/badge/Data_Engineering-ETL-blue?style=for-the-badge)
![Ankara University](https://img.shields.io/badge/Ankara_University-Computer_Engineering-00529B?style=for-the-badge)

Bu depo, **Ankara Üniversitesi Bilgisayar Mühendisliği** bölümünün **BLM4522 - Ağ Tabanlı Paralel Dağıtım Sistemleri** dersi kapsamında geliştirilen veritabanı yönetimi, optimizasyonu, ETL süreçleri ve otomasyon projelerini içermektedir.

---

## 📑 İçindekiler
- [Proje 1: Veritabanı Performans Optimizasyonu ve İzleme](#-proje-1-veritabanı-performans-optimizasyonu-ve-izleme)
- [Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma](#-proje-2-veritabanı-yedekleme-ve-felaketten-kurtarma-planı)
- [Proje 5: Veri Temizleme ve ETL Süreçleri Tasarımı](#-proje-5-veri-temizleme-ve-etl-süreçleri-tasarımı)
- [Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi](#-proje-6-veritabanı-yükseltme-ve-sürüm-yönetimi)
- [Proje 7: Veritabanı Yedekleme ve Otomasyon Çalışması](#-proje-7-veritabanı-yedekleme-ve-otomasyon-çalışması)

---

## 🚀 Projeler

### 🗄️ Proje 1: Veritabanı Performans Optimizasyonu ve İzleme
Bu proje kapsamında; büyük bir veritabanı üzerinde SQL Profiler ve DMV araçlarıyla sorgu izleme, hatalı indekslerin onarımı, fragmentation (parçalanma) stratejileri ve sorgu maliyeti analizleri gerçekleştirilmiştir.
- 📁 **Kaynak Kodlar:** [`/project1-performance`](./project1-performance)
- 📺 **Proje Sunumu:** [YouTube Üzerinden İzle](https://www.youtube.com/watch?v=j72ECIzw1_s)

### 🛡️ Proje 2: Veritabanı Yedekleme ve Felaketten Kurtarma Planı
Bağımsız bir veritabanı üzerinde Full, Differential ve Transaction Log yedekleme görevleri kurgulanmış, senaryo gereği silinen verilerin **Tail-Log Backup** ve **Point-in-Time Restore** yöntemleriyle saniyesi saniyesine kurtarılması sağlanmıştır.
- 📁 **Kaynak Kodlar:** [`/project2-backup`](./project2-backup)
- 📺 **Proje Sunumu:** [YouTube Üzerinden İzle](https://www.youtube.com/watch?v=1rDNclw-mCU)

### 🧹 Proje 5: Veri Temizleme ve ETL Süreçleri Tasarımı
Büyük veri kümelerinin temizlenmesi ve işlenmesi için ETL (Extract, Transform, Load) süreçleri tasarlanmıştır. 
> **Kazanımlar:**
> * **Veri Temizleme:** SQL kullanılarak eksik, tutarsız veya hatalı formatta olan verilerin temizlenmesi.
> * **Veri Dönüştürme:** Farklı kaynaklardan gelen verilerin standartlaştırılarak dönüştürülmesi.
> * **Veri Yükleme & Raporlama:** Verilerin hedef veritabanlarına yüklenmesi ve veri kalitesi raporlarının oluşturulması.
- 📁 **Kaynak Kodlar:** [`/project5-etl`](./project5-etl)
- 📺 **Proje Sunumu:** [YouTube Üzerinden İzle](https://www.youtube.com/watch?v=HCkAYQ_Miho)

### 📈 Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi
Mevcut bir veritabanının daha yeni bir sürüme geçişi için stratejik bir yükseltme planı oluşturulmuştur. 
> **Kazanımlar:**
> * Eski sürümden yeni sürüme geçiş için strateji ve veritabanı yükseltme planı.
> * **DDL Triggers** kullanılarak şema değişikliklerini takip etme ve sürüm yönetimi.
> * Olası sorunlara karşı geri dönüş (rollback) ve yükseltme sonrası test planları.
- 📁 **Kaynak Kodlar:** [`/project6-upgrade`](./project6-upgrade)
- 📺 **Proje Sunumu:** [YouTube Üzerinden İzle](https://www.youtube.com/watch?v=RV0S1G4Q93s)

### ⚙️ Proje 7: Veritabanı Yedekleme ve Otomasyon Çalışması
Veritabanı yönetim süreçlerini optimize etmek amacıyla yedekleme işlemleri tamamen otomatik hale getirilmiştir.
> **Kazanımlar:**
> * **SQL Server Agent** kullanılarak düzenli yedekleme görevlerinin otomatikleştirilmesi.
> * **PowerShell** ve T-SQL scriptleri ile detaylı yedekleme raporları oluşturulması.
> * Yedekleme işlemleri başarısız olduğunda yöneticilere anında bildirim gönderen uyarı mekanizmalarının kurulması.
- 📁 **Kaynak Kodlar:** [`/project7-backupAuto`](./project7-backupAuto)
- 📺 **Proje Sunumu:** [YouTube Üzerinden İzle](https://www.youtube.com/watch?v=HpMqFHUBQNQ)

---
