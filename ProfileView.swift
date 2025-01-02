private func updateProgress() {
    Task {
        await evidenceManager.refreshEvidenceStatus()
        // Update progress after refresh
        for unit in units {
            progress[unit.code] = getProgressForUnit(unit.code)
        }
    }
}