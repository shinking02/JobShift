//
//  OnboardingView.swift
//
//  Created by Adam Lyttle on 2/5/2023.
//
//  adamlyttleapps.com
//  twitter.com/adamlyttleapps
//
//  Usage:
/*
OnboardingView(summary: "Real Estate Calculator", features: [
    Feature(title: "Mortgage Repayments", description: "Easily calculate weekly, monthly and yearly repayments ", icon: "house"),
    Feature(title: "Amortization", description: "Quickly view amortization for the life of the loan", icon: "chart.line.downtrend.xyaxis"),
    Feature(title: "Deposit Calculator", description: "Calculate deposit based on purchase price and savings", icon: "percent"),
    Feature(title: "Ad-Free Experience", description: "Thank you for downloading my app, I hope you enjoy it :-)", icon: "party.popper"),
], color: Color.blue)
*/

import SwiftUI

struct Feature: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String?
}

struct OnboardingView: View {
    @State var summary: String
    @State var detailURL: URL?
    @State var viewModel = OnboardingViewModel()
    @Environment(\.openURL) var openURL
    let features: [Feature]
    let color: Color?
    var body: some View {
        VStack {}
        .hidden()
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(isPresented: $viewModel.showingOnboarding) {
            VStack {
                Text(summary)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical, 50)
                    .multilineTextAlignment(.center)
                Spacer()
                VStack {
                    ForEach(features) { feature in
                        VStack(alignment: .leading) {
                            HStack {
                                if let icon = feature.icon {
                                    Image(systemName: icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, alignment: .center)
                                        .clipped()
                                        .foregroundColor(color ?? Color.blue)
                                        .padding(.trailing, 15)
                                        .padding(.vertical, 10)
                                }
                                VStack(alignment: .leading) {
                                    Text(feature.title)
                                        .fontWeight(.bold)
                                        .font(.system(size: 16))
                                    Text(feature.description)
                                        .font(.system(size: 15))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.bottom, 30)
                Spacer()
                VStack {
                    if let detailURL = detailURL {
                        Button(action: {
                            openURL(detailURL)
                        }, label: {
                            Text("もっとみる")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        })
                        .padding()
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(color ?? Color.blue)
                            .cornerRadius(12)
                            .frame(height: 54)
                        Text("はじめる")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .onDisappear {
                        viewModel.onDisappear()
                    }
                    .onTapGesture {
                        viewModel.startButtonTap()
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 20)
                .padding(.horizontal, 15)
            }
            .padding()
        }
    }
}
