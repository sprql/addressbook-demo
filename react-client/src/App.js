import React, { Component } from 'react';
import './App.css';

const API_URL='http://localhost:9292';
const API_BASIC_AUTHENTICATION_NAME = 'development';
const API_BASIC_AUTHENTICATION_PASSWORD = 'development';

const HEADERS = new Headers();
HEADERS.set('Authorization', 'Basic ' + btoa(API_BASIC_AUTHENTICATION_NAME + ":" + API_BASIC_AUTHENTICATION_PASSWORD));

class ContactRow extends React.Component {
  render() {
    const contact = this.props.contact;
    const name = contact.attributes.first_name + ' ' + contact.attributes.last_name;

    return (
      <tr>
        <td><img width="64" src={API_URL + '/contacts/' + contact.id + '/image'} /></td>
        <td>{name}</td>
        <td>{contact.attributes.phone}</td>
        <td>{contact.attributes.address}</td>
      </tr>
    );
  }
}

class ContactTable extends React.Component {
  render() {
    const rows = [];

    this.props.contacts.forEach((contact) => {
      rows.push(
        <ContactRow
          contact={contact}
          key={contact.id}
        />
      );
    });

    return (
      <table className="table">
        <thead>
          <tr>
            <th>&nbsp;</th>
            <th>Name</th>
            <th>Phone</th>
            <th>Address</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class SearchBar extends React.Component {
  constructor(props) {
    super(props);
    this.handleFilterTextChange = this.handleFilterTextChange.bind(this);
  }

  handleFilterTextChange(e) {
    this.props.onFilterTextChange(e.target.value);
  }

  render() {
    return (
      <form>
        <div className="form-group">
          <input
            className="form-control"
            type="text"
            placeholder="Search..."
            value={this.props.filterText}
            onChange={this.handleFilterTextChange}
          />
        </div>
      </form>
    );
  }
}

function build_contacts(json) {
  return json.data;
}

function fetch_contacts(query) {
  const q = query ? '?query=' + query : '';
  return fetch(API_URL + '/contacts'+ q, { headers: HEADERS })
           .then((response) => response.json())
           .then((json) => build_contacts(json))
           .catch((error) => {
             console.error(error);
             return [];
           });
}

class FilterableContactTable extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      filterText: '',
      data: []
    };

    fetch_contacts().then((data) => {
      this.setState({
         data: data
      })
    })

    this.handleFilterTextChange = this.handleFilterTextChange.bind(this);
  }

  handleFilterTextChange(filterText) {
    fetch_contacts(filterText).then((data) => {
      this.setState({ data: data })
    })

    this.setState({
      filterText: filterText
    });
  }

  render() {
    return (
      <div>
        <SearchBar
          filterText={this.state.filterText}
          onFilterTextChange={this.handleFilterTextChange}
        />
        <ContactTable
          contacts={this.state.data}
        />
      </div>
    );
  }
}

class App extends Component {
  render() {
    return (
      <div className="App container">
        <FilterableContactTable />
      </div>
    );
  }
}

export default App;
