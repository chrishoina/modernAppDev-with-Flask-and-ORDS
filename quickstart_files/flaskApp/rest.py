import requests
from flask import Flask, json, render_template, request, redirect
app = Flask(__name__)

@app.route('/')
def mypage():
    def getJobs():
        response = requests.get("https://bqj5jpf7pvxppq5-adb21.adb.eu-frankfurt-1.oraclecloudapps.com/ords/admin/jobs/")
        list_of_jobs = []

        for jobs in response.json()['items']:
            
            jobList = dict()
            try:
                job_id = jobs['job_id']
                job_title = jobs['job_title']

                jobList['job_id'] = job_id
                jobList['job_title'] = job_title                
                list_of_jobs.append(jobList)
                

            except:
                pass

        return list_of_jobs

    list_of_jobs = getJobs()
    return render_template('home.html', list_ip_mac=list_of_jobs)

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