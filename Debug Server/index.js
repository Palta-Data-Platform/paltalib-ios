const express = require('express')
const app = express()
const port = 3000


app.use(express.urlencoded());
app.use(express.json())

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.post('/event/1', (req, res) => {
    console.log('%c Event log from /event/1 ', 'background: #222; color: #bada55')
    console.log(req.body)
    res.send('Success')
})

app.post('/event/2', (req, res) => {
    console.log('%c Event log from /event/2 ', 'background: #222; color: #bada55')
    console.log(req.body)
    res.send('Success')
})


app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})