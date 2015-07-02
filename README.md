# Kas gi tai?

Čia yra [Vagrant](https://www.vagrantup.com) šablonas, reikalingas pradėti darbą su naujos kartos [Games.lt](http://games.lt) tinklalapio kodu.

# Kaip pasinaudoti šiuo dalyku?

<table>
   <tr>
        <th>
        </th>
      <th>
      Jei naudojatės bent Windows 8.0 Pro (bent Pro lygio versija) arba Windows Server 2012 ir gerai suprantate kaip Hyper-V veikia.
      </th>
      <th>
      Jei naudojate kažką kitą arba neturite jokio supratimo apie Hyper-V
      </th>      
   </tr>
   <tr>
   <td>
   1.
   </td>
   <td colspan="2">
   Įsitikinkite, kad Jūsų kompiuteryje yra įdiegtas <a href="https://www.vagrantup.com">Vagrant</a>. Jei ne, tuomet <a href="https://www.vagrantup.com/downloads.html">atsisiųskite</a> ir įdiekite.
   </td>
   </tr>
   <tr>
   <td>
   2.
   </td>     
   <td>
   Nusikopijuoti <i>config.hyperv-example.json</i> į <i>config.json</i>.
   </td>
      <td>
      Nusikopijuoti <i>config.virtualbox-example.json</i> į <i>config.json</i>.
   </td>
  </tr>
  <tr>
   <td>
   3.
   </td>
   <td colspan="2">
   Pasikeisti pagal save <i>config.json</i> parametrus.
   </td>
   </tr>
      <tr>
   <td>
   4.
   </td>
   <td>
   Hyper-V galite įsidiegti per Windows componentus
   </td>
   <td>
   Reikės atsisiųsti bei įsidiegti <a href="https://www.virtualbox.org/">VirtualBox</a> iš <a href="https://www.virtualbox.org/wiki/Downloads ">https://www.virtualbox.org/wiki/Downloads </a>.   
   </td> 
   </tr>
   <tr>
   <td>
   5.
   </td>
      <td>
      Nukeliavus į lokaliame diske esantį katalogą, kuriame yra šis tekstas, paleisti <br />
      <code>vagrant up --provider hyperv</code>
   </td>
      <td>
      Nukeliavus į lokaliame diske esantį katalogą, kuriame yra šis tekstas, paleisti <br />
      <code>vagrant up --provider virtualbox</code>
   </td>   
   </tr>
      <td>
   6.
   </td>
      <td colspan="2">
      Palaukti kol baigs
   </td>
   
   </tr>
   <tr>
      <td>
   7.
   </td>
      <td colspan="2">
      Susikurti iš ką tik atsiradusio <i>impresscms</i> katalogo projektą ir jame keisti failus, o rezultatą matyti naršyklėje.
   </td>   
   </tr>
</table>

Adresas, kokį reikia surinkti naršyklėje priklauso nuo to ar naudojamas *Hyper-V* ar *VirtualBox* bei nuo *config.json*. *Hyper-V* atveju greičiausiai bus *http://VIRTUALIOS_DĖŽUTĖS_IP/*, o *VirtualBox* atveju *http://localhost:PORTAS/*, kur portas yra nurodytas config.json failiuke. Pagal nutylėjimą jis yra 8080. T.y., *VirtualBox* atveju adresas pagal nutylėjimą būtų http://localhost:8080/

# Licenzija

Skaitykite [LICENSE](https://raw.githubusercontent.com/GamesLT/web-devbox/master/LICENSE) failiuką (anglų kalba) dėl turinio licenzijos. Licenzija galioja tik šitai repozitorijai.
