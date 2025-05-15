//PALESTRA 1.1.1 VISIONE (sfondo semplice)
//PROPOSTA
import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Palette colori

extension Color {

    
    //ORDINE PALETTE DA 5: PaletteGreen2, PaletteGreen6, PaletteGreen10, PaletteGreen11, PaletteGreen9
    // #006809, #00900a, #0bb01a, #89ec0f, #a1f21f, /// #0EFF01
    
    // #212030
    static let PaletteGreen1  = Color(red: 33/255,  green: 48/255,  blue: 32/255)
    // #051306  (RGB 5, 19, 6)
    static let PaletteGreen1Alt1 = Color(red:   5/255, green:  19/255, blue:   6/255)
    // #0A1F08  (RGB 10, 31, 8)
    static let PaletteGreen1Alt2 = Color(red:  10/255, green:  31/255, blue:   8/255)
    // #0F280F  (RGB 15, 40, 15)
    static let PaletteGreen1Alt3 = Color(red:  15/255, green:  40/255, blue:  15/255)
    // #132F10  (RGB 19, 47, 16)
    static let PaletteGreen1Alt4 = Color(red:  19/255, green:  47/255, blue:  16/255)
    // #173916  (RGB 23, 57, 22)
    static let PaletteGreen1Alt5 = Color(red:  23/255, green:  57/255, blue:  22/255)
    // #006809
    static let PaletteGreen2  = Color(red:  0/255,  green:104/255,  blue:  9/255)
    // #3F5C3D
    static let PaletteGreen3  = Color(red: 63/255,  green: 92/255,  blue: 61/255)
    // #00900A
    static let PaletteGreen4  = Color(red:  0/255,  green:144/255,  blue: 10/255)
    // #008A0B  (RGB 0, 138, 11)
    static let PaletteGreen4Alt2 = Color(red:   0/255, green: 138/255, blue:  11/255)
    // #2E8C2A
    static let PaletteGreen5  = Color(red: 46/255,  green:140/255,  blue: 42/255)
    // #0BB01A
    static let PaletteGreen6  = Color(red: 11/255,  green:176/255,  blue: 26/255)
    // #08B11A  (RGB 8, 177, 26)
        static let PaletteGreen6Alt2 = Color(red:   8/255, green: 177/255, blue:  26/255)
    // #42B53C
    static let PaletteGreen7  = Color(red: 66/255,  green:181/255,  blue: 60/255)
    // #00EF01
    static let PaletteGreen8  = Color(red:  0/255,  green:239/255,  blue:  1/255)
    // #0EFF01
    static let PaletteGreen9  = Color(red: 14/255,  green:255/255,  blue:  1/255)
    // #89EC0F
    static let PaletteGreen10 = Color(red:137/255,  green:236/255,  blue: 15/255)
    // #A1F21F
    static let PaletteGreen11 = Color(red:161/255,  green:242/255,  blue: 31/255)

}


// MARK: – a very simple wave shape
struct WaveShape: Shape {
    /// how tall the wave is
    var amplitude: CGFloat = 80
    /// where it sits (0…1)
    var yOffset: CGFloat = 0.85

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.height * yOffset
        // start at left bottom
        p.move(to: CGPoint(x: 0, y: rect.height))
        // line up to start of curve
        p.addLine(to: CGPoint(x: 0, y: midY))
        // single simple curve across
        p.addQuadCurve(
            to: CGPoint(x: rect.width, y: midY),
            control: CGPoint(x: rect.width/2, y: midY + amplitude)
        )
        // down to bottom right
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.closeSubpath()
        return p
    }
}

// MARK: – the simplified background view
struct FluidBackground: View {
    var body: some View {
        GeometryReader { _ in
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.PaletteGreen1Alt3,
                    Color.PaletteGreen2,
                    Color.PaletteGreen6,
                    Color.PaletteGreen8,
                    //Color.PaletteGreen9,
        
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            .padding(.bottom, -300)
        }
    }
}


// MARK: – VisioneIngressoView con NavigationLink

struct VisioneIngressoView: View {
    @EnvironmentObject var data: AppData

    @State private var showExport        = false
    @State private var showImport        = false
    @State private var showImportConfirm = false
    @State private var importURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                FluidBackground()
                
                VStack(alignment: .leading, spacing: 24) {

                    // Titolo + calendario
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PALESTRA")
                                .font(.system(size: 40, weight: .heavy))
                                .foregroundColor(.white)
                            
                            Text("Sempre in forma!")
                                .font(.title2.weight(.medium))
                                .foregroundColor(.white)
                                .bold()
                        }
                        Spacer()
                        NavigationLink {
                            ContentView(initialSelection: .calendar)
                                .environmentObject(data)
                                .withPalestraButton()
                                .navigationBarTitleDisplayMode(.inline) // (optional)
                        } label: {
                            Circle()
                                .fill(Color.PaletteGreen10)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "calendar")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.PaletteGreen2)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // SCHEDA ATTIVA
                    Menu {
                        ForEach(data.plans) { plan in
                            Button { data.activePlanId = plan.id } label: {
                                HStack {
                                    Text(plan.name)
                                    Spacer()
                                    if plan.id == data.activePlanId {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text( // Text("SCHEDA ATTIVA")
                            data.plans
                                .first { $0.id == data.activePlanId }?
                                .name
                            ?? "Seleziona"
                        )
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.PaletteGreen1Alt5) //2
                            .cornerRadius(16)
                    }

                    // Preview AREA PRINCIPALE
                    NavigationLink {
                        ContentView(initialSelection: .main)
                            .environmentObject(data)
                            .withPalestraButton()
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                            //    .padding(.top, 6)
                            (data.suggestNextSuggestions().first ?? Text("Nessuna scheda attiva"))
                            .foregroundColor(Color.white)

                            let lastThree = Array(
                                data.workoutLogs.sorted { $0.date > $1.date }.prefix(3)
                            ).reversed()
                            if !lastThree.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Spacer()
                                    Text("ALLENAMENTI:").bold()
                                    ForEach(lastThree, id: \.id) { e in
                                        Text(e.date.formatted("dd/MM/yyyy") + ": " +
                                             (e.isLongPause ? "-" : e.muscleGroups.map(\.name).joined(separator: " + ")))
                                    }
                                }
                                .font(.headline).foregroundColor(Color.white)
                            }

                            Spacer(minLength: 0)

                            HStack {
                                Spacer()
                                NavigationLink {
                                    ContentView(initialSelection: .construction)
                                        .environmentObject(data)
                                        .withPalestraButton()
                                } label: {
                                    Circle()
                                        .fill(Color.PaletteGreen10)
                                        .frame(width: 70, height: 70)
                                        .overlay(
                                            Image(systemName: "dumbbell")       // or "dumbbell.fill" for the filled version
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(Color.PaletteGreen2)
                                        )
                                        .contentShape(Circle())               // ensure taps register on whole circle
                                } /*label: {
                                   Text("SCHEDE ALLENAMENTO")
                                       .font(.headline)
                                       .foregroundColor(.white)
                                       .padding(.horizontal, 16)
                                       .padding(.vertical, 8)
                                       .background(Color.PaletteGreen1Alt5)
                                       .cornerRadius(12)
                               }*/ //vecchio bottone allenamento, non si sa mai

                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 280, alignment: .leading)
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(24)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                    
                    /*
                    // Export / Import
                    HStack(spacing: 16) {
                        Button("Esporta i dati") { showExport = true }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.PaletteGreen10)
                            .foregroundColor(.PaletteGreen1)
                            .cornerRadius(16)

                        Button("Importa salvataggio") { showImport = true }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.PaletteGreen10)
                            .foregroundColor(.PaletteGreen1)
                            .cornerRadius(16)
                    }
                    */
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 100)
            }
            // fileExporter / fileImporter
            .fileExporter(
                isPresented: $showExport,
                document: BackupDocument(data: makeBackupData()),
                contentType: .json,
                defaultFilename: "PalestraBackup"
            ) { _ in }
            .fileImporter(
                isPresented: $showImport,
                allowedContentTypes: [.json]
            ) { result in
                if case .success(let url) = result {
                    importURL = url
                    showImportConfirm = true
                }
            }
            .alert("Sicuro di voler importare il backup e sovrascrivere tutti i dati?",
                   isPresented: $showImportConfirm) {
                Button("Importa", role: .destructive) { performImport(from: importURL) }
                Button("Annulla", role: .cancel) { }
            }

        }
        
    }

    private func makeBackupData() -> Data {
        let backup = Backup(plans: data.plans, activePlanId: data.activePlanId,
                            workoutLogs: data.workoutLogs, historyStartMonth: data.historyStartMonth)
        return (try? JSONEncoder().encode(backup)) ?? Data()
    }
    private func performImport(from url: URL?) {
        guard let url = url,
              let imported = try? Data(contentsOf: url),
              let backup = try? JSONDecoder().decode(Backup.self, from: imported)
        else { return }
        data.plans = backup.plans
        data.activePlanId = backup.activePlanId
        data.workoutLogs = backup.workoutLogs
        data.historyStartMonth = backup.historyStartMonth
    }
}

// MARK: - Modelli di backup

struct Backup: Codable {
    var plans: [TrainingPlan]
    var activePlanId: UUID?
    var workoutLogs: [WorkoutLogEntry]
    var historyStartMonth: Date?
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    var data: Data

    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let fileData = configuration.file.regularFileContents
        else { throw CocoaError(.fileReadCorruptFile) }
        data = fileData
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: data)
    }
}

// MARK: - Modelli core

struct TrainingPlan: Identifiable, Codable {
    var id: UUID
    var name: String
    var length: Int
    var muscleGroups: [MuscleGroup]
    var days: [DayPlan]
    var startAfterLongPauseDayId: UUID?
    var minLongPauseDays: Int
    var strictMode: Bool
    var showDetailsColumn: Bool
}

struct MuscleGroup: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
}

struct DayPlan: Identifiable, Codable {
    var id: UUID
    var muscleGroups: [MuscleGroup]
    var title: String
    var description: String
}

struct WorkoutLogEntry: Identifiable, Codable {
    var id: UUID
    var date: Date
    var muscleGroups: [MuscleGroup]
    var isLongPause: Bool
}

// MARK: - AppData

class AppData: ObservableObject {
    @Published var plans: [TrainingPlan] = []
    @Published var activePlanId: UUID?
    @Published var workoutLogs: [WorkoutLogEntry] = []
    @Published var historyStartMonth: Date?

    private var saveCancellable: AnyCancellable?

    init() {
        load()
        if plans.isEmpty {
            addDefaultPlan()
        } else if activePlanId == nil {
            activePlanId = plans.first?.id
        }
        saveCancellable = Publishers
            .CombineLatest4($plans, $activePlanId, $workoutLogs, $historyStartMonth)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _,_,_,_ in self?.save() }
    }

    var activePlan: TrainingPlan? {
        get { activePlanId.flatMap { id in plans.first { $0.id == id } } }
        set {
            guard let p = newValue,
                  let idx = plans.firstIndex(where: { $0.id == p.id })
            else { return }
            plans[idx] = p
        }
    }

    func addDefaultPlan() {
        let p = TrainingPlan(
            id: UUID(),
            name: "Nuova scheda",
            length: 1,
            muscleGroups: [],
            days: [ DayPlan(id: UUID(), muscleGroups: [], title: "", description: "") ],
            startAfterLongPauseDayId: nil,
            minLongPauseDays: 10,
            strictMode: false,
            showDetailsColumn: false
        )
        plans.append(p)
        activePlanId = p.id
    }

    private func docs(_ name: String) -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
    }

    func save() {
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601
        if let d = try? enc.encode(plans) { try? d.write(to: docs("plans.json")) }
        if let id = activePlanId {
            UserDefaults.standard.set(id.uuidString, forKey: "activePlanId")
        }
        if let d = try? enc.encode(workoutLogs) {
            try? d.write(to: docs("logs.json"))
        }
        let fmt = ISO8601DateFormatter()
        if let h = historyStartMonth {
            UserDefaults.standard.set(fmt.string(from: h), forKey: "historyStartMonth")
        } else {
            UserDefaults.standard.removeObject(forKey: "historyStartMonth")
        }
    }

    func load() {
        let dec = JSONDecoder(); dec.dateDecodingStrategy = .iso8601
        if let d = try? Data(contentsOf: docs("plans.json")),
           let arr = try? dec.decode([TrainingPlan].self, from: d) {
            plans = arr
        }
        if let s = UserDefaults.standard.string(forKey: "activePlanId"),
           let id = UUID(uuidString: s),
           plans.contains(where: { $0.id == id }) {
            activePlanId = id
        }
        if let d = try? Data(contentsOf: docs("logs.json")),
           let arr = try? dec.decode([WorkoutLogEntry].self, from: d) {
            workoutLogs = arr
        }
        let fmt = ISO8601DateFormatter()
        if let hs = UserDefaults.standard.string(forKey: "historyStartMonth"),
           let dt = fmt.date(from: hs) {
            historyStartMonth = dt
        }
    }

    // MARK: - Suggestion Algorithm


    func suggestNextSuggestions() -> [Text] {
        guard let plan = activePlan else {
            return [ Text("Nessuna scheda attiva. Vai alla Costruzione schede.") ]
        }
        let cycle = plan.days
        let n = cycle.count
        let logs = workoutLogs.sorted { $0.date < $1.date }
        let today = Calendar.current.startOfDay(for: Date())
        let usedToday = logs.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
        let label = usedToday ? "Domani" : "Oggi"
        let cutoff = Calendar.current.date(byAdding: .day, value: -plan.minLongPauseDays, to: today)!

        let recentWorkoutIndices = logs.indices
            .filter { logs[$0].date >= cutoff && !logs[$0].isLongPause }
            .reversed()

        for i0 in recentWorkoutIndices {
            let strict = plan.strictMode
            var bestStarts: [Int] = []
            var maxLen = 0

            for j in 0..<n {
                var len = 0, offset = 0, nonPauseCount = 0
                while i0 - offset >= 0 && nonPauseCount < plan.minLongPauseDays {
                    let logEntry = logs[i0 - offset]
                    let dayPlan  = cycle[(j - offset % n + n) % n]

                    if logEntry.isLongPause {
                        if dayPlan.muscleGroups.isEmpty {
                            len += 1; offset += 1; continue
                        } else { break }
                    }

                    if match(log: logEntry, day: dayPlan, strict: strict) {
                        len += 1; nonPauseCount += 1; offset += 1
                    } else { break }
                }

                if len > 0 {
                    if len > maxLen {
                        maxLen = len; bestStarts = [j]
                    } else if len == maxLen {
                        bestStarts.append(j)
                    }
                }
            }

            if maxLen > 0 {
                return bestStarts.enumerated().map { index, start in
                    let next = cycle[(start + 1) % n]
                    let prefix = index == 0 ? "\(label) devi fare:" : "Oppure:"
                    let groups = next.muscleGroups.map(\.name).joined(separator: " + ")
                    let hasTitle = !next.title.trimmingCharacters(in: .whitespaces).isEmpty
                    let desc = next.description.trimmingCharacters(in: .whitespacesAndNewlines)

                    // costruisco il Text passo-passo
                    let titlePart: Text = {
                      if hasTitle {
                        return Text("\(next.title) (\(groups))").bold()
                      } else {
                        return Text(groups).bold()
                      }
                    }()

                    var t = Text(prefix + " ") + titlePart
                    if !desc.isEmpty {
                        t = t + Text("\n" + desc).italic()
                    }
                    return t
                }
            }
        }

        // dopo lunga pausa
        if let plan = activePlan,
           let startId = plan.startAfterLongPauseDayId,
           let idx = plan.days.firstIndex(where: { $0.id == startId }) {
            let d = plan.days[idx]
            let groups = d.muscleGroups.map(\.name).joined(separator: " + ")
            let hasTitle = !d.title.trimmingCharacters(in: .whitespaces).isEmpty
            let desc = d.description.trimmingCharacters(in: .whitespacesAndNewlines)

            
            // --- Build the raw string you want to display in the middle -------------
            let titlePartString: String = hasTitle
                ? "\(d.title) (\(groups))"
                : groups

            // --- Decide what to show ------------------------------------------------
            let titlePart: Text            // declare once – we’ll assign below
            var t: Text                    // the final text to put on screen

            if titlePartString.isEmpty {
                // Nothing to show in the middle → show a one‑line warning instead
                titlePart = Text("pausa").bold()   // still give it a value in case you need it
                t = Text("Suggerimenti: cambia il giorno di inizio scheda nelle impostazioni (e verifica di aver seguito la scheda correttamente)") //se ho superato la lunga pausa senza trovare nulla e l'utente ha selezionato un giorno di pausa come inizio scheda
            } else {
                // Normal case
                titlePart = Text(titlePartString).bold()
                t = Text("\(label) devi fare: ")
                    + titlePart
                    + Text(" dopo lunga pausa")
                
                if !desc.isEmpty {
                    t = t + Text("\n" + desc).italic()
                }
            }

            return [ t ]
        }

        return [ Text("Suggerimenti: seleziona un giorno di inizio scheda nelle impostazioni (o verifica di aver seguito la scheda correttamente)") ] //se l'utente non ha scelto un giorno di inizio scheda
    }
    
    private func match(log: WorkoutLogEntry, day: DayPlan, strict: Bool) -> Bool {
        let logSet = Set(log.muscleGroups.map(\.name))
        let daySet = Set(day.muscleGroups.map(\.name))
        if daySet.isEmpty { return logSet.isEmpty }
        return strict ? logSet.isSubset(of: daySet) : !logSet.isDisjoint(with: daySet)
    }

    // MARK: - Long Pause & Logging

    func insertLongPause(from start: Date, to end: Date) {
        let cal = Calendar.current
        var d = cal.startOfDay(for: start)
        let last = cal.startOfDay(for: end)
        while d <= last {
            if let i = workoutLogs.firstIndex(where: { cal.isDate($0.date, inSameDayAs: d) }) {
                workoutLogs[i].muscleGroups = []
                workoutLogs[i].isLongPause = true
            } else {
                workoutLogs.append(WorkoutLogEntry(id: UUID(), date: d, muscleGroups: [], isLongPause: true))
            }
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }
    }

    func saveWorkout(on date: Date, groups: [MuscleGroup]) {
        let cal = Calendar.current
        if let i = workoutLogs.firstIndex(where: { cal.isDate($0.date, inSameDayAs: date) }) {
            workoutLogs[i].muscleGroups = groups
            workoutLogs[i].isLongPause = groups.isEmpty
        } else {
            workoutLogs.append(WorkoutLogEntry(id: UUID(), date: date, muscleGroups: groups, isLongPause: groups.isEmpty))
        }
    }
}

// MARK: - Date Helpers

extension Date {
    func formatted(_ fmt: String = "EEEE dd/MM/yy") -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = fmt
        return f.string(from: self)
    }
    var startOfMonth: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: self)
        )!
    }
}

// MARK: - Entry point

@main
struct PalestraApp: App {
    @StateObject private var data = AppData()
    var body: some Scene {
        WindowGroup {
            VisioneIngressoView()
                .environmentObject(data)

        }
    }
}

// MARK: - ContentView (TabView parametrica)

struct ContentView: View {
    @EnvironmentObject var data: AppData
    enum Tab { case main, construction, calendar }
    @State private var selection: Tab

    init(initialSelection: Tab = .main) {
        _selection = State(initialValue: initialSelection)
    }

    var body: some View {
        TabView(selection: $selection) {
            MainView()
                .tabItem { Label("Area principale", systemImage: "house") }
                .tag(Tab.main)
            ConstructionView()
                .tabItem { Label("Costruzione schede", systemImage: "square.grid.2x2") }
                .tag(Tab.construction)
            CalendarView()
                .tabItem { Label("Calendario allenamenti", systemImage: "calendar") }
                .tag(Tab.calendar)
        }
        .environmentObject(data)
    }
}

// MARK: - MainView
// copia qui esattamente il tuo MainView originale, senza modifiche

// MARK: - ConstructionView
// copia qui esattamente il tuo ConstructionView originale, senza modifiche

// MARK: - ConstructionDayCell, DropHandler, DayDetailCell, DetailEditor, SettingsView
// MARK: - CalendarView, MonthYearPicker, MonthView, DayCell, DayLogView, SelectionBlock
// in coda copia tutte le altre strutture originali, esattamente come nel file Swift che già usi.


// MARK: - MainView

struct MainView: View {
    @EnvironmentObject var data: AppData

    @State private var showExport = false
    @State private var showImport = false
    @State private var showImportConfirm = false
    @State private var importURL: URL?

    var body: some View {
        // All’inizio del body della tua View:
        let lastTen = Array(
            data.workoutLogs
                .sorted(by: { $0.date > $1.date })
                .prefix(10)
        ).reversed()

        let history = computeFullHistory()

        ScrollView {
            VStack(alignment: .leading) {
                // Sezione 1: Scheda attiva + suggerimenti
                VStack(alignment: .leading, spacing: 16) {
                    
                    //PLAN PICKER, TENDINA SELEZIONE SCHEDA ATTIVA
                    Menu {
                        ForEach(data.plans) { plan in
                            Button {
                                data.activePlanId = plan.id
                            } label: {
                                HStack {
                                    Text(plan.name)
                                    Spacer()
                                    if plan.id == data.activePlanId {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    }
                                }
                                .frame(maxWidth: .infinity)   // tappable row fills available width
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("Scheda")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack(spacing: 4) {
                                Text(
                                    data.plans
                                        .first { $0.id == data.activePlanId }?
                                        .name
                                    ?? "Seleziona"
                                )
                                Image(systemName: "chevron.down")
                            }
                            .font(.headline).bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(16)
                            .frame(maxWidth: .infinity)   // ← stretch the label
                        }
                    }
                    .frame(maxWidth: .infinity)            // ← make the Menu container stretch

                    Spacer()
                    
                    let suggestions: [Text] = data.suggestNextSuggestions()
                    ForEach(Array(suggestions.enumerated()), id: \.0) { _, suggestion in
                        suggestion
                            .font(.body)
                    }
                }
                .padding(.bottom, 32)

                // Sezione 2: ALLENAMENTI (mostra solo se ci sono elementi)
                if !lastTen.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ALLENAMENTI:").bold()
                        ForEach(lastTen, id: \.id) { e in
                            HStack {
                                Text(e.date.formatted("dd/MM/yyyy") + ":")
                                Text(e.isLongPause
                                    ? "-"
                                    : e.muscleGroups.map(\.name).joined(separator: " + ")
                                )
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }

                // Sezione 3: SCHEDA
                VStack(alignment: .leading, spacing: 8) {
                    Text("SCHEDA:").bold()
                    if let plan = data.activePlan {
                        ForEach(plan.days) { d in
                            let blocks = d.muscleGroups.isEmpty
                                ? "-"
                                : d.muscleGroups.map(\.name).joined(separator: " + ")
                            if d.title.isEmpty {
                                Text(blocks)
                            } else {
                                Text("\(d.title): \(blocks)")
                            }
                        }
                    }
                }
                .padding(.bottom, 32)

                // Sezione 4: STORICO ALLENAMENTI (mostra solo se ci sono elementi)
                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STORICO ALLENAMENTI:").bold()
                        ForEach(history, id: \.self) { line in
                            Text(line)
                        }
                    }
                    .padding(.bottom, 32)
                }

                // Sezione 5: Backup
                Spacer().padding(100)
                HStack {
                    Button("Esporta backup") { showExport = true }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                    Button("Importa backup") { showImport = true }
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .fileExporter(
            isPresented: $showExport,
            document: BackupDocument(data: makeBackupData()),
            contentType: .json,
            defaultFilename: "PalestraBackup"
        ) { _ in }
        .fileImporter(
            isPresented: $showImport,
            allowedContentTypes: [.json]
        ) { result in
            if case .success(let url) = result {
                importURL = url
                showImportConfirm = true
            }
        }
        .alert("Sicuro di voler importare il backup e sovrascrivere tutti i dati?", isPresented: $showImportConfirm) {
            Button("Importa", role: .destructive) {
                performImport(from: importURL)
            }
            Button("Annulla", role: .cancel) {}
        }
    }

    private func computeFullHistory() -> [String] {
        let sorted = data.workoutLogs.sorted(by: { $0.date < $1.date })
        var result: [String] = []
        var i = 0
        _ = Calendar.current
        while i < sorted.count {
            let e = sorted[i]
            if e.isLongPause {
                var j = i
                while j < sorted.count && sorted[j].isLongPause { j += 1 }
                let len = j - i
                if len > 15 {
                    let s = sorted[i].date.formatted("dd/MM/yyyy")
                    let t = sorted[j-1].date.formatted("dd/MM/yyyy")
                    result.append("->SALTO TEMPORALE dal \(s) al \(t)")
                } else {
                    for k in i..<j {
                        result.append("\(sorted[k].date.formatted("dd/MM/yyyy")): -")
                    }
                }
                i = j
            } else {
                result.append("\(sorted[i].date.formatted("dd/MM/yyyy")): \(sorted[i].muscleGroups.map(\.name).joined(separator: " + "))")
                i += 1
            }
        }
        return result
    }

    private func makeBackupData() -> Data {
        let backup = Backup(plans: data.plans, activePlanId: data.activePlanId,
                            workoutLogs: data.workoutLogs, historyStartMonth: data.historyStartMonth)
        return (try? JSONEncoder().encode(backup)) ?? Data()
    }

    private func performImport(from url: URL?) {
        guard let url = url,
              let imported = try? Data(contentsOf: url),
              let backup = try? JSONDecoder().decode(Backup.self, from: imported)
        else { return }
        data.plans = backup.plans
        data.activePlanId = backup.activePlanId
        data.workoutLogs = backup.workoutLogs
        data.historyStartMonth = backup.historyStartMonth
    }
}


// MARK: - ConstructionView

struct ConstructionView: View {
    @EnvironmentObject var data: AppData
    @State private var showAddGroup = false
    @State private var newGroupName = ""
    @State private var showSettings = false
    @State private var pendingLength = 1
    @State private var confirmRemove = false

    var body: some View {
        Group {
            if data.activePlan == nil {
                Text("Nessuna scheda attiva")
                    .onAppear { data.addDefaultPlan() }
            } else {
                mainContent
                    .onChange(of: data.activePlanId) { _, _ in
                        pendingLength = data.activePlan?.length ?? 1
                    }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // inset region is above the TabView bar
            VStack(spacing: 0) {
                Spacer().frame(height: 0)      // lift it 20pts above the tab bar
                bottomBar
            }
            .background(Color(.systemBackground))
        }
        // MARK:— modals & alerts
        .sheet(isPresented: $showAddGroup) { addGroupSheet }
        .sheet(isPresented: $showSettings) {
            SettingsView(pendingLength: $pendingLength)
                .environmentObject(data)
        }
        .alert("Rimuovere i giorni extra?", isPresented: $confirmRemove) {
            Button("Rimuovi", role: .destructive) {
                adjustPlanLength(to: pendingLength, force: true)
            }
            Button("Annulla", role: .cancel) {
                pendingLength = data.activePlan!.length
            }
        }
        .onChange(of: pendingLength) { _, new in
            adjustPlanLength(to: new, force: false)
        }
    }

    // MARK: main content above the custom bottom bar
    private var mainContent: some View {
        let plan = data.activePlan!
        return VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 6) {
                // Gruppi muscolari column
                VStack {
                    Text("Gruppi muscolari").bold()
                    ScrollView {
                        ForEach(plan.muscleGroups) { g in
                            Text(g.name)
                                .frame(maxWidth: 100)
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 112))
                                .onDrag {
                                    NSItemProvider(object: g.id.uuidString as NSString)
                                }
                        }
                    }
                }
                .frame(width: 140)

                // Descrizioni + Scheda side by side
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 0) {
                        if plan.showDetailsColumn {
                            VStack(alignment: .leading) {
                                Text("Descrizioni").bold().padding(.leading, 8)
                                ScrollView {
                                    ForEach(plan.days) { day in
                                        let idx = plan.days.firstIndex { $0.id == day.id }!
                                        DayDetailCell(dayIndex: idx)
                                            .environmentObject(data)
                                            .frame(minWidth: 80)
                                
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Scheda").bold().padding(.leading, 4)
                            ScrollView {
                                ForEach(plan.days) { day in
                                    let idx = plan.days.firstIndex { $0.id == day.id }!
                                    ConstructionDayCell(dayIndex: idx)
                                        .environmentObject(data)
                                }
                            }
                        }
                        .padding (.leading, 12)
                    }
                }
                .padding(.trailing, 10)

            }

        }
        .padding(.top, 30)
        .padding(.leading, 10)
    }

    // MARK: custom bottom bar
    private var bottomBar: some View {
        let plan = data.activePlan!
        return HStack(spacing: 2) {      // 1pt white separator
            // ── LEFT PANEL ──
            VStack(spacing: 0) {
                Spacer()
                Button {
                    showAddGroup = true
                } label: {
                    Image("croceMuscoli")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                        )
                }
                .frame(width: 145, height: 145)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 4)
            //.frame(maxWidth: .infinity)

            // ── CENTER PANEL ──
            VStack(spacing: 2) {
                Button {
                    data.activePlan?.showDetailsColumn.toggle()
                } label: {
                    Text("Mostra/Nascondi\nDescrizioni")
                        .font(.subheadline).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 108, height: 60)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 6)

                Spacer(minLength: 0)

                Menu {
                    ForEach(data.plans) { p in
                        Button {
                            data.activePlanId = p.id
                        } label: {
                            HStack {
                                Text(p.name)
                                Spacer()
                                if p.id == data.activePlanId {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                } label: {
                    VStack(spacing: -6) {
                        Text("Scheda")
                            .font(.caption).bold()
                            .foregroundColor(.gray)
                        HStack(spacing: 0) {
                            Text(plan.name)
                            Image(systemName: "chevron.down")
                        }
                        .font(.caption).bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 1)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                        .frame(width: 108, height: 80)
                    }
                    //.frame(width: 108, height: 78)
                    
                    
                    
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, 16)
            .padding(.top, 4)
            .frame(width: 112)
            

            // ── RIGHT PANEL ──
            VStack(spacing: 0) {
                Button {
                    data.addDefaultPlan()
                } label: {
                    Text("Crea nuova\nscheda")
                        .font(.subheadline).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 108, height: 46)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                
                Button {
                    duplicateCurrentPlan()
                } label: {
                    Text("Duplica\nscheda")
                        .font(.subheadline).bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 108, height: 46)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.top, 6)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 0)

                Button("Impostazioni") {
                    pendingLength = plan.length
                    showSettings = true
                }
                //.buttonStyle(.borderedProminent) // standard blue style
                .frame(width: 108, height: 46)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.trailing, 0)
        }
        .frame(height: 144)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .padding(.bottom, 20)
        .padding(.top, 10)
        .padding(.leading, 8)
    }
    

    // MARK: add-group sheet
    private var addGroupSheet: some View {
        NavigationView {
            Form {
                Section(header:
                    Text("Nuovo Gruppo Muscolare")
                        .font(.title).bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                ) {
                    TextField("Petto, Spalle, Schiena, Bicipiti, Gambe, etc...", text: $newGroupName)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Mattoncini")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        showAddGroup = false
                        newGroupName = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi") {
                        var p = data.activePlan!
                        p.muscleGroups.append(
                            MuscleGroup(id: UUID(), name: newGroupName)
                        )
                        data.activePlan = p
                        showAddGroup = false
                        newGroupName = ""
                    }
                }
            }
        }
    }

    // MARK: helpers

    private func duplicateCurrentPlan() {
        guard let old = data.activePlan else { return }
        let newGroups = old.muscleGroups.map {
            MuscleGroup(id: UUID(), name: $0.name)
        }
        let mapOldToNew = Dictionary(
            uniqueKeysWithValues: zip(old.muscleGroups.map(\.id), newGroups)
        )
        let newDays = old.days.map { day in
            let cloned = day.muscleGroups.compactMap { mapOldToNew[$0.id] }
            return DayPlan(
                id: UUID(),
                muscleGroups: cloned,
                title: day.title,
                description: day.description
            )
        }
        var newStart: UUID? = nil
        if let oldStart = old.startAfterLongPauseDayId,
           let idx = old.days.firstIndex(where: { $0.id == oldStart }) {
            newStart = newDays[idx].id
        }
        let newPlan = TrainingPlan(
            id: UUID(),
            name: old.name + " - copia",
            length: old.length,
            muscleGroups: newGroups,
            days: newDays,
            startAfterLongPauseDayId: newStart,
            minLongPauseDays: old.minLongPauseDays,
            strictMode: old.strictMode,
            showDetailsColumn: old.showDetailsColumn
        )
        data.plans.append(newPlan)
        data.activePlanId = newPlan.id
    }

    private func adjustPlanLength(to newLen: Int, force: Bool) {
        var p = data.activePlan!
        if newLen < p.length {
            let slice = p.days[newLen..<p.length]
            let hasData = slice.contains {
                !$0.muscleGroups.isEmpty ||
                !$0.title.isEmpty ||
                !$0.description.isEmpty
            }
            if hasData && !force {
                confirmRemove = true
                return
            }
            p.days = Array(p.days.prefix(newLen))
        } else if newLen > p.length {
            p.days.append(contentsOf:
                (p.length..<newLen).map { _ in
                    DayPlan(id: UUID(), muscleGroups: [], title: "", description: "")
                }
            )
        }
        p.length = newLen
        data.activePlan = p
    }
}


// MARK: - ConstructionDayCell

struct ConstructionDayCell: View {
    @EnvironmentObject var data: AppData
    let dayIndex: Int

    var body: some View {
        if let plan = data.activePlan, dayIndex < plan.days.count {
            let day = plan.days[dayIndex]
            HStack {
                VStack(alignment: .leading) {
                    Text("Giorno \(dayIndex + 1)").font(.caption)
                    HStack {
                        ForEach(Array(day.muscleGroups.enumerated()), id: \.offset) { _, mg in
                            Text(mg.name)
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.3)))
                                .onTapGesture {
                                    var p = plan
                                    p.days[dayIndex].muscleGroups.removeAll { $0.id == mg.id }
                                    data.activePlan = p
                                }
                        }
                        Spacer()
                    }
                }
                .padding(6)
            }
            .background(RoundedRectangle(cornerRadius: 8).stroke())
            .frame(width: 200)
            .onDrop(of: [UTType.text], delegate: DropHandler(dayIndex: dayIndex, data: data))
        }
    }
}

// MARK: - DropHandler

struct DropHandler: DropDelegate {
    let dayIndex: Int
    let data: AppData

    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.text]).first else { return false }
        item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { raw, _ in
            if let d = raw as? Data,
               let s = String(data: d, encoding: .utf8),
               let uuid = UUID(uuidString: s),
               let template = data.plans.first(where: { $0.id == data.activePlanId })?
                   .muscleGroups.first(where: { $0.id == uuid })
            {
                let newMG = MuscleGroup(id: UUID(), name: template.name)
                DispatchQueue.main.async {
                    var p = data.activePlan!
                    p.days[dayIndex].muscleGroups.append(newMG)
                    data.activePlan = p
                }
            }
        }
        return true
    }
}

// MARK: - DayDetailCell

struct DayDetailCell: View {
    @EnvironmentObject var data: AppData
    let dayIndex: Int
    @State private var editing = false

    var body: some View {
        if let plan = data.activePlan, dayIndex < plan.days.count {
            let day = plan.days[dayIndex]
            VStack(alignment: .leading) {
                Text(day.title.isEmpty ? "Titolo giorno \(dayIndex+1)" : day.title)
                    .foregroundColor(.gray)
                Text(day.description.isEmpty ? "Descrizione allenamento \(dayIndex+1)" : day.description)
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).stroke())
            .onTapGesture { editing = true }
            .sheet(isPresented: $editing) {
                DetailEditor(dayIndex: dayIndex, isPresented: $editing).environmentObject(data)
            }
        }
    }
}

// MARK: - DetailEditor

struct DetailEditor: View {
    @EnvironmentObject var data: AppData
    let dayIndex: Int
    @Binding var isPresented: Bool
    @State private var titleText = ""
    @State private var descText = ""

    var body: some View {
        VStack {
            HStack {
                Button("Annulla") { isPresented = false }
                Spacer()
                Button("Salva") {
                    var p = data.activePlan!
                    p.days[dayIndex].title = titleText
                    p.days[dayIndex].description = descText
                    data.activePlan = p
                    isPresented = false
                }
            }
            .padding()
            Divider()
            TextField("Titolo giorno", text: $titleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextEditor(text: $descText)
                .frame(height: 200)
                .border(Color.gray)
                .padding()
            Spacer()
        }
        .onAppear {
            let day = data.activePlan!.days[dayIndex]
            titleText = day.title
            descText = day.description
        }
        .onChange(of: data.activePlan?.days.count ?? 0) { old, newCount in
            if dayIndex >= newCount { isPresented = false }
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @EnvironmentObject var data: AppData
    @Environment(\.dismiss) var dismiss
    @Binding var pendingLength: Int
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationView {
            Form {
                Section("Nome scheda") {
                    TextField("Nome", text: Binding(
                        get: { data.activePlan!.name },
                        set: { data.activePlan!.name = $0 }
                    ))
                }
                Section("Lunghezza (giorni)") {
                    Stepper("\(pendingLength) giorni", value: $pendingLength, in: 1...100)
                }
                Section("Primo giorno della scheda dopo lunga pausa") {
                    Picker("Seleziona", selection: Binding<UUID?>(
                        get: { data.activePlan?.startAfterLongPauseDayId },
                        set: { data.activePlan?.startAfterLongPauseDayId = $0 }
                    )) {
                        Text("Nessuno").tag(UUID?.none)
                        if let days = data.activePlan?.days {
                            ForEach(days) { d in
                                Text(d.title.isEmpty
                                     ? "Giorno \(days.firstIndex(where: { $0.id==d.id })!+1)"
                                     : d.title)
                                    .tag(Optional(d.id))
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                Section("Dopo quanti giorni si considera lunga pausa?") {
                    Stepper("\(data.activePlan!.minLongPauseDays) giorni",
                            value: Binding(
                                get: { data.activePlan!.minLongPauseDays },
                                set: { data.activePlan!.minLongPauseDays = $0 }
                            ),
                            in: 1...100)
                }
                Section("Logica scheda") {
                    Toggle("Da seguire strettamente", isOn: Binding(
                        get: { data.activePlan!.strictMode },
                        set: { data.activePlan!.strictMode = $0 }
                    ))
                }
                // solo se ho più di una scheda
                if data.plans.count > 1 {
                    Section {
                        Button("Elimina scheda", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle("Impostazioni")
            .alert("Sei sicuro di voler eliminare questa scheda?", isPresented: $showDeleteConfirm) {
                Button("Elimina", role: .destructive) {
                    if let id = data.activePlanId {
                        data.plans.removeAll { $0.id == id }
                        data.activePlanId = data.plans.first?.id
                    }
                    dismiss()
                }
                Button("Annulla", role: .cancel){}
            }
        }
    }
}


// MARK: - CalendarView

struct CalendarView: View {
    @EnvironmentObject var data: AppData
    @State private var selectedMonth = Date()
    @State private var showRange = false
    @State private var rangeStart = Date()
    @State private var rangeEnd = Date()
    @State private var showHistory = false

    private var months: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let curr = today.StartOfMonth
        let logMonths = data.workoutLogs.map { $0.date.StartOfMonth }
        let earliestLog = logMonths.min() ?? curr
        let sixAgo = cal.date(byAdding: .month, value: -6, to: curr)!
        let defaultEarliest = min(earliestLog, sixAgo)
        let earliest = data.historyStartMonth?.StartOfMonth ?? defaultEarliest

        var m = earliest, arr: [Date] = []
        while m <= curr {
            arr.append(m)
            m = cal.date(byAdding: .month, value: 1, to: m)!
        }
        if let next = cal.date(byAdding: .month, value: 1, to: curr) {
            arr.append(next)
        }
        return arr
    }

    var body: some View {
        VStack {
            HStack {
                
                //PLAN PICKER, TENDINA SELEZIONE SCHEDA ATTIVA
                Menu {
                    ForEach(data.plans) { plan in
                        Button {
                            data.activePlanId = plan.id
                        } label: {
                            HStack {
                                Text(plan.name)
                                Spacer()
                                if plan.id == data.activePlanId {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            // così il tappable area è larga tutta la riga
                            .frame(maxWidth: .infinity)
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text("Scheda")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack(spacing: 4) {
                            Text(
                                data.plans
                                    .first { $0.id == data.activePlanId }?
                                    .name
                                ?? "Seleziona"
                            )
                            Image(systemName: "chevron.down")
                        }
                        .font(.headline).bold()
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                        
                    }
                }
                
                /*Text(data.activePlan?.name ?? "")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.green)
                    .cornerRadius(8)
                 */
                
                Spacer()
                Button("Data inizio registro") { showHistory = true }
                Spacer()
                Button("Inserire pausa lunga") {
                    rangeStart = Date()
                    rangeEnd = Date()
                    showRange = true
                }
            }
            .padding()

            TabView(selection: $selectedMonth) {
                ForEach(months, id: \.self) { m in
                    MonthView(month: m).tag(m)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                selectedMonth = months.last { $0 <= Calendar.current.startOfDay(for: Date()) }
                    ?? months.first!
            }
        }
        // SHEET STORICO
        .sheet(isPresented: $showHistory) {
            NavigationView {
                // Calcola i due limiti una sola volta, subito prima del Form
                let previousMonthDate = Calendar.current.date(
                    byAdding: .month,
                    value: -1,
                    to: Date()
                )!  // mese precedente a oggi

                let tenYearsBeforeDate = months.first.flatMap {
                    Calendar.current.date(byAdding: .year,
                                          value: -10,
                                          to: $0)
                }

                Form {
                    if let tenYearsBefore = tenYearsBeforeDate {
                        // Caso normale: abbiamo sia months.first che i limiti
                        MonthYearPicker(
                            date: Binding(
                                get: { data.historyStartMonth ?? Date() },
                                set: { newDate in
                                    // clamp tra tenYearsBefore e previousMonthDate
                                    let clamped = min(
                                        max(newDate, tenYearsBefore),
                                        previousMonthDate
                                    )
                                    data.historyStartMonth = clamped
                                }
                            ),
                            minYear: Calendar.current.component(.year, from: tenYearsBefore),
                            maxYear: Calendar.current.component(.year, from: previousMonthDate)
                        )
                    } else {
                        // Fallback se months.first è nil: limiti solo al mese precedente
                        MonthYearPicker(
                            date: Binding(
                                get: { data.historyStartMonth ?? Date() },
                                set: { newDate in
                                    let clamped = min(newDate, previousMonthDate)
                                    data.historyStartMonth = clamped
                                }
                            ),
                            minYear: Calendar.current.component(.year, from: previousMonthDate),
                            maxYear: Calendar.current.component(.year, from: previousMonthDate)
                        )
                    }
                }
                .navigationTitle("Mostra storico da")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla") { showHistory = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salva") { showHistory = false }
                    }
                }
            }
        }
        // SHEET PAUSA LUNGA
        .sheet(isPresented: $showRange) {
            NavigationView {
                Form {
                    DatePicker("Da", selection: $rangeStart, in: ...Date(), displayedComponents: .date)
                    DatePicker("A",  selection: $rangeEnd,   in: rangeStart...Date(), displayedComponents: .date)
                }
                .navigationTitle("Inserisci pausa lunga")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla") { showRange = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Salva") {
                            data.insertLongPause(from: rangeStart, to: rangeEnd)
                            showRange = false
                        }
                    }
                }
            }
        }
        // italiano per tutti i formatter
        .environment(\.locale, Locale(identifier: "it_IT"))
    }
}

// Component riusabile per scegliere solo Mese/Anno (giorno fisso = 1)
struct MonthYearPicker: View {
    @Binding var date: Date
    let minYear: Int
    let maxYear: Int

    private let calendar = Calendar.current
    private let monthNames: [String] = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "it_IT")
        return df.monthSymbols.map { $0.capitalized }
    }()

    private var years: [Int] {
        Array(minYear...maxYear)
    }

    var body: some View {
        HStack {
            Picker("Mese", selection: monthBinding) {
                ForEach(1...12, id: \.self) { idx in
                    Text(monthNames[idx-1]).tag(idx)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Picker("Anno", selection: yearBinding) {
                ForEach(years, id: \.self) { y in
                    Text("\(y)").tag(y)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }

    private var monthBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.month, from: date) },
            set: { newMonth in
                var comps = calendar.dateComponents([.year, .month], from: date)
                comps.month = newMonth
                comps.day = 1
                date = calendar.date(from: comps)!
            }
        )
    }

    private var yearBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.year, from: date) },
            set: { newYear in
                var comps = calendar.dateComponents([.year, .month], from: date)
                comps.year = newYear
                comps.day = 1
                date = calendar.date(from: comps)!
            }
        )
    }
}

// Estensione di supporto per ottenere l’inizio del mese
extension Date {
    var StartOfMonth: Date {
        Calendar.current.date(from:
            Calendar.current.dateComponents([.year, .month], from: self)
        )!
    }
}

// MARK: - MonthView //visione mensile dentro calendario allenamento

// MARK: - MonthView

struct MonthView: View {
    @EnvironmentObject var data: AppData
    let month: Date
    @State private var showDeleteAlert = false

    // 1) Computed property che verifica se esiste almeno un log nel mese
    private var hasEntries: Bool {
        let cal = Calendar.current
        let monthStart = month  // month è già StartOfMonth
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart) else { return false }
        return data.workoutLogs.contains { log in
            log.date >= monthStart && log.date < nextMonth
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(daysIn(month), id: \.self) { date in
                    DayCell(date: date).environmentObject(data)
                }

                // 2) Mostra bottone SOLO se hasEntries == true
                if hasEntries {
                    Spacer(minLength: 20)

                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Elimina allenamenti del mese")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal)
                    .alert("Conferma eliminazione", isPresented: $showDeleteAlert) {
                        Button("Elimina", role: .destructive) {
                            deleteMonth()
                        }
                        Button("Annulla", role: .cancel) { }
                    } message: {
                        Text("Sei sicuro di voler eliminare tutti gli allenamenti del mese selezionato?")
                    }
                }
            }
            .padding()
        }
    }

    private func deleteMonth() {
        let cal = Calendar.current
        let monthStart = month
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart) else { return }
        data.workoutLogs.removeAll { log in
            log.date >= monthStart && log.date < nextMonth
        }
    }

    private func daysIn(_ month: Date) -> [Date] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: month) else { return [] }
        let comps = cal.dateComponents([.year, .month], from: month)
        return range.compactMap { day -> Date? in
            var c = comps; c.day = day
            return cal.date(from: c)
        }
    }
}

// MARK: - DayCell

struct DayCell: View {
    @EnvironmentObject var data: AppData
    let date: Date
    @State private var showEditor = false

    private var entry: WorkoutLogEntry? {
        data.workoutLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    var body: some View {
        HStack {
            Text(date.formatted())
            Spacer()
            if let e = entry {
                Text(e.isLongPause
                     ? "-"
                     : e.muscleGroups.map(\.name).joined(separator: " + "))
                    .foregroundColor(e.isLongPause ? .gray : .primary)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke())
        .contentShape(Rectangle())
        .onTapGesture {
            if date <= Date() { showEditor = true }
        }
        .sheet(isPresented: $showEditor) {
            DayLogView(date: date).environmentObject(data)
        }
    }
}

// MARK: - DayLogView

struct DayLogView: View {
    @EnvironmentObject var data: AppData
    let date: Date
    @Environment(\.dismiss) var dismiss

    @State private var selected: Set<UUID> = []
    @State private var newGroups: [MuscleGroup] = []
    @State private var adding = false
    @State private var newName = ""

    private var existing: WorkoutLogEntry? {
        data.workoutLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// true exactly when preview() == "Pausa"
    private var isPause: Bool {
        preview() == "Pausa"
    }

    var body: some View {
        VStack {
            HStack {
                if existing != nil {
                    // swap Svuota <> Elimina based on isPause
                    Button(isPause ? "Elimina" : "Svuota", role: .destructive) {
                        if isPause {
                            // delete the log for this day
                            data.workoutLogs.removeAll {
                                Calendar.current.isDate($0.date, inSameDayAs: date)
                            }
                            dismiss()
                        } else {
                            // just clear your in-memory selection
                            selected.removeAll()
                            newGroups.removeAll()
                        }
                    }
                }

                Spacer()

                Text("Allenamento \(date.formatted("dd/MM/yyyy"))")
                    .font(.headline)

                Spacer()

                Button("Salva") {
                    let planGroups = data.activePlan?.muscleGroups.filter { selected.contains($0.id) } ?? []
                    let custom = newGroups.filter { selected.contains($0.id) }
                    data.saveWorkout(on: date, groups: planGroups + custom)
                    dismiss()
                }
            }
            .padding()

            Text(preview())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Button("Altro") { adding = true }
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.orange.opacity(0.3)))

                    ForEach(data.activePlan?.muscleGroups ?? []) { g in
                        SelectionBlock(group: g, isSelected: selected.contains(g.id)) {
                            toggle(g.id)
                        }
                    }
                    ForEach(newGroups) { g in
                        SelectionBlock(group: g, isSelected: selected.contains(g.id)) {
                            toggle(g.id)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $adding) {
            NavigationView {
                Form {
                    TextField("Nome gruppo", text: $newName)
                }
                .navigationTitle("Altro Gruppo")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annulla") { adding = false; newName = "" }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Aggiungi") {
                            let g = MuscleGroup(id: UUID(), name: newName)
                            newGroups.append(g)
                            selected.insert(g.id)
                            adding = false; newName = ""
                        }
                    }
                }
            }
        }
        .onAppear {
            if let e = existing {
                selected = Set(e.muscleGroups.map(\.id))
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
    }

    private func preview() -> String {
        let names = (data.activePlan?.muscleGroups.filter { selected.contains($0.id) }.map(\.name) ?? [])
            + newGroups.filter { selected.contains($0.id) }.map(\.name)
        return names.isEmpty ? "Pausa" : names.joined(separator: " + ")
    }
}

// MARK: - SelectionBlock

struct SelectionBlock: View {
    let group: MuscleGroup
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(group.name)
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.yellow.opacity(0.5) : Color.clear))
            .onTapGesture(perform: action)
    }
}

// Reusable modifier for a centred “PALESTRA” button
struct PalestraNavButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)          // ⬅︎ keep bar height = 44 pt
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationLink {
                        VisioneIngressoView()
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("PALESTRA")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)           // ⬅︎ much smaller vertical padding
                            .background(Color.PaletteGreen4Alt2)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)                     // removes extra link padding
                }
            }
    }
}

extension View {
    func withPalestraButton() -> some View { modifier(PalestraNavButton()) }
}



// Reusable modifier for Back button of navigation link to remove it back in ingresso visione view
struct IndietroBackButton: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)

    }
}

extension View {
    func withIndietroBack() -> some View {
        modifier(IndietroBackButton())
    }
}
