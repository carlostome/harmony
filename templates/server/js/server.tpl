var express = require('express'),
    bodyParser = require('body-parser'),
    mongoose = require('mongoose'),
    app = express(),
    args = process.argv.slice(2);

app.use(bodyParser.json());

mongoose.connect(args[1]);

{{#requiresAuth}}
// User registration and authentication
var UserAutoGeneratedSchema = new mongoose.Schema({
  login : { type: String, required: true, unique: true, index: true, dropDupes: true },
  password: { type: String, required: true },
});

UserAutoGeneratedSchema.set('toJSON', {
  transform: function (doc, ret, options) {
    delete ret._id
    delete ret.__v
    delete ret.password
  }
});

var UserAutoGenerated = mongoose.model('UserAutoGenerated', UserAutoGeneratedSchema);

app.post('/u_auth/register', function (req, res) {
  UserAutoGenerated.create(new UserAutoGenerated(req.body), function(err, obj) {
    if (err) {
      res.status(500).send(err);
      return; 
    }
    res.status(201).send();
   });
});

app.post('/u_auth/:login/:password', function (req, res) {
  UserAutoGenerated.find({ login: req.params.login }, function(err, result) {
      if (err) {
        console.error(err);
        res.status(500).send();
        return;
      }
      if (result.length == 0) {
        res.status(401).send('Invalid credentials');
      } else {
        if (result[0].password != req.params.password) {
          res.status(401).send('Invalid credentials');
        } else {
          //TODO implement token
          res.status(200).json({token: "TODOTOKEN"});
        }
      }
  });
});
{{/requiresAuth}}

{{#schema}}
var {{schemaName}}Schema = new mongoose.Schema({
{{#schemaVars}}{{#isList}}
  {{varName}} : { type: [{{#isStruct}}{{varType}}Schema{{/isStruct}}{{^isStruct}}{{varType}}{{/isStruct}}]
               {{/isList}}{{^isList}}
  {{varName}} : { type: {{#isStruct}}{{varType}}Schema{{/isStruct}}{{^isStruct}}{{varType}}{{/isStruct}}
               {{/isList}} {{#isUnique}}, unique : true {{/isUnique}}{{#isKey}}, index: true, dropDupes: true {{/isKey}} {{#isRequired}}, required: true {{/isRequired}} {{#isEnum}}, enum: [{{/isEnum}}{{#isEnum}}{{#values}}'{{value}}',{{/values}}{{/isEnum}}{{#isEnum}}]{{/isEnum}}{{/isStruct}} },
{{/schemaVars}}
});

{{schemaName}}Schema.set('toJSON', {
  transform: function (doc, ret, options) {
    {{^hasKeyField}}ret.id = ret._id{{/hasKeyField}}
    {{#schemaVars}}{{#isHidden}}delete ret.{{varName}};{{/isHidden}}{{/schemaVars}}
    delete ret._id
    delete ret.__v
  }
});

{{^hasKeyField}}
{{schemaName}}Schema.set('toObject', {
  transform : function (doc, ret, options) {
    ret._id = ret.id
    delete ret.id
  }
});
{{/hasKeyField}}

var {{schemaName}} = mongoose.model('{{schemaName}}', {{schemaName}}Schema);

{{/schema}}

{{#schema}}
{{#schemaRoute}}
app.get('{{&value}}{{#requiresAuth}}/:token{{/requiresAuth}}', function(req, res) {
{{#requiresAuth}}
  if (token != "TODOTOKEN") {
    res.status(403).send();
    return;
  }
{{/requiresAuth}}
        {{schemaName}}.find(function(err, result) {
          if (err) return console.error(err);
            res.send(result);
         });
});

app.get('{{&value}}/:id{{#requiresAuth}}/:token{{/requiresAuth}}', function(req, res) {
{{#requiresAuth}}
  if (req.params.token != "TODOTOKEN") {
    res.status(403).send();
    return;
  }
{{/requiresAuth}}
        {{schemaName}}.find({ {{#hasKeyField}}{{keyField}}{{/hasKeyField}}{{^hasKeyField}}_id{{/hasKeyField}}: req.params.id }, function(err, result) {
          if (err) return console.error(err);
            if (result.length == 0) {
              res.status(404).send('Not Found');
            } else {
              res.send(result[0]);
            }
         });
});

{{#writable}}
{{^hasKeyField}}
app.post('{{&value}}{{#requiresAuth}}/:token{{/requiresAuth}}', function(req, res) {
{{#requiresAuth}}
  if (req.params.token != "TODOTOKEN") {
    res.status(403).send();
    return;
  }
{{/requiresAuth}}
  {{schemaName}}.create(new {{schemaName}}(req.body), function(err, obj) {
    if (err) {
      res.status(500).send(err);
      return;  
    }
    res
      .status(201)
      .json({id : obj._id});
   });
});
{{/hasKeyField}}

app.put('{{&value}}/:id{{#requiresAuth}}/:token{{/requiresAuth}}', function(req, res) {
{{#requiresAuth}}
  if (req.params.token != "TODOTOKEN") {
    res.status(403).send();
    return;
  }
{{/requiresAuth}}
  {{schemaName}}.update({ {{#hasKeyField}}{{keyField}}{{/hasKeyField}}{{^hasKeyField}}_id{{/hasKeyField}} : req.params.id }, req.body, {upsert : true, runValidators : true}, function(err, result) {
    if (err) {
      res.status(500).send(err);
    } else {
      res.status(200).send();
    }
  });
});

app.delete('{{&value}}/:id{{#requiresAuth}}/:token{{/requiresAuth}}', function(req, res) {
{{#requiresAuth}}
  if (req.params.token != "TODOTOKEN") {
    res.status(403).send();
    return;
  }
{{/requiresAuth}}
  {{schemaName}}.remove({ {{#hasKeyField}}{{keyField}}{{/hasKeyField}}{{^hasKeyField}}_id{{/hasKeyField}}: req.params.id}, function(err, result) {
      if (err) { 
        res.status(500).send(err);
        return;
    }});
    res.status(200).send();
});
{{/writable}}
{{/schemaRoute}}
{{/schema}}

app.listen(args[0]);
