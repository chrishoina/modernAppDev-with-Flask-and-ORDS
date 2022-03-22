import requests
from flask import Flask, json, render_template, request, redirect, jsonify
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
        return list_of_stores

    list_of_stores = getStores()
    return render_template('home.html', lists_stores=list_of_stores)

@app.route('/myorders')
def myOrders():
    def getOrders():
        response = requests.get("https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/gary/hotdogs/getorders/")
        list_of_orders = []

        for orders in response.json()['items']:
            
            ordersList = dict()
            try:
                order_id = orders['order_id']
                product_name = orders['product_name']
                product_description = orders['product_description']
                quantity = orders['quantity']
                total_price = orders['total_price']

                ordersList['order_id'] = order_id
                ordersList['product_name'] = product_name                
                ordersList['product_description'] = product_description
                ordersList['quantity'] = quantity                
                ordersList['total_price'] = total_price

                list_of_orders.append(ordersList)           

            except:
                pass
        return list_of_orders

    list_of_orders = getOrders()
    return render_template('myorders.html', list_of_orders=list_of_orders)

@app.route('/get_price')
def get_hotdog_price():
    a = request.args.get('a')
    url = "https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/gary/hotdogs/getprice/"+a
    print(url)
    response = requests.get(url)

    for ids in response.json()['items']:
        
        idList = dict()
        try:
            product_price = ids['product_price']       

        except:
            pass

    return jsonify(product_price)

@app.route('/order') 
def order():
    def getHotDogs():    
        response = requests.get("https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/gary/products/")
        list_of_hotdogs = []

        for hotdogs in response.json()['items']:
            
            hotdogList = dict()
            try:

                product_id = hotdogs['product_id']
                product_name = hotdogs['product_name']

                hotdogList['product_id'] = product_id
                hotdogList['product_name'] = product_name
                
                list_of_hotdogs.append(hotdogList)
                

            except:
                pass

        return list_of_hotdogs

    list_of_hotdogs = getHotDogs()
    return render_template('order.html', list_of_hotdogs_return=list_of_hotdogs)  


@app.route('/result', methods = ['POST', 'GET'])    
def result():
   url = "https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/gary/hotdogs/createorder/"
   if request.method == 'POST':
        product_id = request.form.get('product_id')
        quantity = request.form.get('quantity')
        total = request.form.get('total')

        json_data = { "PRODUCT_ID": product_id, "QUANTITY": quantity, "TOTAL_PRICE": total }
    
        headers = {'Content-type':'application/json', 'Accept':'application/json'}
        response = requests.post(url, json=json_data, headers=headers)
        return redirect('myorders')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)