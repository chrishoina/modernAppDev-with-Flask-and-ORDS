import requests
from flask import Flask, json, render_template, request, redirect
app = Flask(__name__)

@app.route('/')
def mypage():
    def getStores():
        response = requests.get("https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/gary/stores/")
        list_of_stores = []

        for stores in response.json()['items']:
            
            storeList = dict()
            try:
                store_name = stores['store_name']
                store_location = stores['store_location']
                store_latlong = stores['store_latlong']

                storeList['store_name'] = store_name
                storeList['store_location'] = store_location                
                storeList['store_latlong'] = store_latlong                     
                list_of_stores.append(storeList)           

            except:
                pass
        print(list_of_stores)
        return list_of_stores

    list_of_stores = getStores()
    return render_template('home.html', lists_stores=list_of_stores)

@app.route('/form') 
def student():
    def getIDs():    
        response = requests.get("https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/test/")
        list_of_id = []

        for ids in response.json()['items']:
            
            idList = dict()
            try:
                id = ids['id']
                idList['id'] = id
                list_of_id.append(idList)
                

            except:
                pass

        return list_of_id

    list_of_id = getIDs()
    return render_template('form.html', list_of_id_return=list_of_id)  
    
@app.route('/result', methods = ['POST', 'GET'])    
def result():
   url = "https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/test/"
   if request.method == 'POST':
        id = request.form.get('id')
        json_data = { "id":id}
    
        headers = {'Content-type':'application/json', 'Accept':'application/json'}
        response = requests.post(url, json=json_data, headers=headers)
        return redirect('form')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)