//
//  ContentView.swift
//  delicousNotes
//
//  Created by Долаан Ховалыг on 04.01.2024.
//

import SwiftUI
import Foundation

struct ContentView: View {
    let recipes: [Recipe] = loadRecipesFromJSON()
    var body: some View {
        RecipeListView(recipes: recipes)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func loadRecipesFromJSON() -> [Recipe] {
    guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        print("ERROR")
        return []
    }
    do {
        let recipes = try JSONDecoder().decode([Recipe].self, from: data)
        print(recipes)
        return recipes
    } catch {
        print("Error decoding JSON: \(error)")
        return []
    }
}

struct Ingredient: Decodable {
    let id: Int
    let name: String
}

struct RecipeStep: Decodable {
    let ingredients: [Ingredient]?
    let number: Int
    let step: String
}

struct Recipe: Decodable {
    let name: String
    let image_url: String
    let steps: [RecipeStep]
}

struct RecipeListView: View {
    let recipes: [Recipe]

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(recipes, id: \.name) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeListItemView(recipe: recipe)
                    }
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeListItemView: View {
    let recipe: Recipe

    var body: some View {
        HStack {
            Image(recipe.image_url)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            Text(recipe.name)
        }
    }
}

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        VStack {
            Image(recipe.image_url)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            Text(recipe.name)
                .font(.title)
                .padding()
            TabView {
                ForEach(recipe.steps, id: \.number) { step in
                    RecipeStepView(step: step)
                        .padding()
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .navigationTitle(recipe.name)
    }
}

struct RecipeStepView: View {
    let step: RecipeStep

    var body: some View {
        VStack(alignment: .leading) {
            Text("Step \(step.number)")
                .font(.headline)
            Text(step.step)
                .padding(.leading)
            if let ingredients = step.ingredients, !ingredients.isEmpty {
                Text("Ingredients:")
                    .font(.subheadline)
                ForEach(ingredients, id: \.id) { ingredient in
                    Text("- \(ingredient.name)")
                        .padding(.leading)
                }
            }
        }
        .padding()
    }
}
