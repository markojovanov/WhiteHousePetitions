import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var clearFilterWords =  UIBarButtonItem()
    var filterWords = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(credits))
        clearFilterWords = UIBarButtonItem(title: "Clear search",
                                      style: .plain,
                                      target: self,
                                      action: #selector(clearSearchPetitions))
        filterWords = UIBarButtonItem(title: "Search",
                                      style: .plain,
                                      target: self,
                                      action: #selector(searchPetitions))
        navigationItem.leftBarButtonItem = filterWords
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self ] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            self?.showError()
        }
    }
    @objc func clearSearchPetitions() {
        filteredPetitions.removeAll()
        navigationItem.leftBarButtonItem = filterWords
        tableView.reloadData()
    }
    @objc func searchPetitions() {
        let ac = UIAlertController(title: "Filter petitions",
                                    message: nil,
                                    preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self,weak ac] action in
            guard let word = ac?.textFields?[0].text else { return }
            self?.submitWord(searchByWord: word)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func submitWord(searchByWord: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            let lowercasedWord = searchByWord.lowercased()
            self?.filteredPetitions.removeAll(keepingCapacity: true)
            for petition in self!.petitions {
                if petition.title.lowercased().contains(lowercasedWord) {
                    self?.filteredPetitions.append(petition)
                }
                else if petition.body.lowercased().contains(lowercasedWord) {
                    self?.filteredPetitions.append(petition)
                }
            }
        }
        navigationItem.leftBarButtonItem = clearFilterWords
        DispatchQueue.main.async {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
    @objc func credits() {
        let ac = UIAlertController(title: "Credits",
                                   message: "Data comes from the We The People API of the Whitehouse.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    func showError() {
        DispatchQueue.main.async {
            [weak self] in
            let ac = UIAlertController(title: "Loading error",
                                   message: "There was a problem loading the feed; please check your connection and try again.",
                                   preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPetitions.isEmpty {
            return petitions.count
        } else {
            return filteredPetitions.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        if filteredPetitions.isEmpty {
            let petition = petitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.title
            return cell
        } else {
            let petition = filteredPetitions[indexPath.row]
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.title
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        if filteredPetitions.isEmpty {
            vc.detailItem = petitions[indexPath.row]
        } else {
            vc.detailItem = filteredPetitions[indexPath.row]
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    func parse(json: Data) {
        let jsonDecoder = JSONDecoder()
        if let jsonPetitons = try? jsonDecoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitons.results
            DispatchQueue.main.async {
                [weak self] in
                self?.tableView.reloadData()
            }
        } else {
            showError()
        }
    }
}

