const app = Vue.createApp({

    el: '#main',
    
    data () {
        return {
          customers: []
        }
        
    },

    mounted:function(){
        this.fetchAPIData()
    },

    methods: {

        fetchAPIData( ) {


            //fetch("http://databasecicd.com:8080/ords/test19/demo/test/test/", {
            fetch("https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/customers/", {    
                method: "GET",
                headers: {

                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Credentials": "true ",
                    "Access-Control-Allow-Methods": "OPTIONS, GET, POST",
                    "Access-Control-Allow-Headers": "Content-Type, Depth, User-Agent, X-File-Size, X-Requested-With, If-Modified-Since, X-File-Name, Cache-Control",
                    "Origin" : "http://databasecicd.com:8080"
                    
                    
                }

    })
    .then(response => response.json())
    .then(data => {
        this.info = data.count;
        this.customers = data.items;

        console.log(data.items);

      })
  

        .catch(err => {
            console.log(err);
        });

}
    }

})