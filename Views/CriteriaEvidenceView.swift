ForEach(selectedOutcome?.sortedPerformanceCriteria ?? [], id: \.code) { criteria in
    Button(action: {
        selectedCriteria = criteria
    }) {
        HStack {
            Text(criteria.code)
            Text(criteria.description)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 