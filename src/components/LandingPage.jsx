import React from 'react';
import './LandingPage.css';

/**
 * Main landing page component with hero section, features, and footer
 * Follows single responsibility principle by focusing on layout composition
 */
const LandingPage = () => {
  return (
    <div className="landingpage-container">
      {/* Hero Section */}
      <section className="landingpage-hero">
        <div className="landingpage-hero-content">
          <h1 className="landingpage-title">
            Welcome to Our Amazing Platform
          </h1>
          <p className="landingpage-subtitle">
            Build faster, scale better, and innovate with confidence using our cutting-edge tools and services.
          </p>
          <div className="landingpage-cta-buttons">
            <button className="landingpage-btn landingpage-btn-primary">
              Get Started
            </button>
            <button className="landingpage-btn landingpage-btn-secondary">
              Learn More
            </button>
          </div>
        </div>
        <div className="landingpage-hero-image">
          <div className="landingpage-placeholder-image">
            🚀
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="landingpage-features">
        <div className="landingpage-features-container">
          <h2 className="landingpage-section-title">Why Choose Us?</h2>
          <div className="landingpage-features-grid">
            <div className="landingpage-feature-card">
              <div className="landingpage-feature-icon">⚡</div>
              <h3 className="landingpage-feature-title">Lightning Fast</h3>
              <p className="landingpage-feature-description">
                Experience blazing fast performance with our optimized infrastructure and modern architecture.
              </p>
            </div>
            <div className="landingpage-feature-card">
              <div className="landingpage-feature-icon">🔒</div>
              <h3 className="landingpage-feature-title">Secure & Reliable</h3>
              <p className="landingpage-feature-description">
                Enterprise-grade security with 99.9% uptime guarantee to keep your data safe and accessible.
              </p>
            </div>
            <div className="landingpage-feature-card">
              <div className="landingpage-feature-icon">🎨</div>
              <h3 className="landingpage-feature-title">Beautiful Design</h3>
              <p className="landingpage-feature-description">
                Stunning, responsive interfaces that work seamlessly across all devices and screen sizes.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="landingpage-footer">
        <div className="landingpage-footer-content">
          <div className="landingpage-footer-section">
            <h4 className="landingpage-footer-title">Product</h4>
            <ul className="landingpage-footer-links">
              <li><a href="#features">Features</a></li>
              <li><a href="#pricing">Pricing</a></li>
              <li><a href="#docs">Documentation</a></li>
            </ul>
          </div>
          <div className="landingpage-footer-section">
            <h4 className="landingpage-footer-title">Company</h4>
            <ul className="landingpage-footer-links">
              <li><a href="#about">About</a></li>
              <li><a href="#contact">Contact</a></li>
              <li><a href="#careers">Careers</a></li>
            </ul>
          </div>
          <div className="landingpage-footer-section">
            <h4 className="landingpage-footer-title">Connect</h4>
            <div className="landingpage-social-links">
              <a href="#" className="landingpage-social-link">Twitter</a>
              <a href="#" className="landingpage-social-link">GitHub</a>
              <a href="#" className="landingpage-social-link">LinkedIn</a>
            </div>
          </div>
        </div>
        <div className="landingpage-footer-bottom">
          <p>&copy; 2024 Your Company. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
};

export default LandingPage; 