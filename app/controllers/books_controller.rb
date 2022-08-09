class BooksController < ApplicationController
  before_action :ensure_correct_user, only: [:edit,:update]

  def show
    @new_book = Book.new
    @book = Book.find(params[:id])
    @user = @book.user
    @book_comment = BookComment.new
    @book_detail = Book.find(params[:id])
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book_detail.id)
      current_user.view_counts.create(book_id: @book_detail.id)
    end
  end

  def index
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorites).
       sort_by {|x|
        x.favorite_users.includes(:favorites).where(created_at: from...to).size
      }.reverse
    @book = Book.new
    @today_book = Book.created_today
    @created_1days_ago = Book.created_days_ago(1)
    @created_2days_ago = Book.created_days_ago(2)
    @created_3days_ago = Book.created_days_ago(3)
    @created_4days_ago = Book.created_days_ago(4)
    @created_5days_ago = Book.created_days_ago(5)
    @created_6days_ago = Book.created_days_ago(6)
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end

end
